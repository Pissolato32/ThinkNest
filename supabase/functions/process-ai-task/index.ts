import { createClient } from "npm:@supabase/supabase-js@2";

const MAX_ATTEMPTS = 3;
const url = Deno.env.get("SUPABASE_URL")!;
const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
const aiBaseUrl = Deno.env.get("THINKNEST_AI_BASE_URL");
const aiKey = Deno.env.get("THINKNEST_AI_API_KEY");
const model = Deno.env.get("THINKNEST_AI_MODEL") ?? "default";
const cors = {"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"authorization, x-client-info, apikey, content-type"};

const reply = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {status, headers:{...cors,"Content-Type":"application/json"}});

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", {headers:cors});
  if (req.method !== "POST") return reply({error:"Method not allowed"},405);
  if (!aiBaseUrl || !aiKey) return reply({error:"Cloud AI provider is not configured"},503);

  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) return reply({error:"Authentication required"},401);
  const db = createClient(url, anonKey, {global:{headers:{Authorization:auth}}});
  const {data:{user}} = await db.auth.getUser();
  if (!user) return reply({error:"Invalid authentication"},401);

  const body = await req.json().catch(() => null) as {task_id?:string}|null;
  if (!body?.task_id) return reply({error:"task_id is required"},400);

  const {data: task} = await db.from("ai_tasks")
    .select("id,project_id,status,attempts,payload_json")
    .eq("id",body.task_id).single();
  if (!task) return reply({error:"AI Task not found"},404);
  if (task.attempts >= MAX_ATTEMPTS) return reply({task_id:task.id,status:"FAILED"});
  if (task.status !== "PENDING") return reply({task_id:task.id,status:task.status,accepted:false});

  const attempts = task.attempts + 1;
  const {data: claimed,error:claimError} = await db.from("ai_tasks")
    .update({status:"RUNNING",attempts, last_error:null,updated_at:new Date().toISOString()})
    .eq("id",task.id).eq("status","PENDING").lt("attempts",MAX_ATTEMPTS)
    .select("id,project_id,status,attempts,payload_json").maybeSingle();
  if (claimError) return reply({error:claimError.message},409);
  if (!claimed) return reply({task_id:task.id,status:"RUNNING",accepted:false});

  const fail = async (error:string) => {
    await db.from("ai_tasks").update({
      status: attempts >= MAX_ATTEMPTS ? "FAILED" : "PENDING",
      last_error:error,updated_at:new Date().toISOString()
    }).eq("id",task.id);
  };

  const [{data:project},{data:dna},{data:messages}] = await Promise.all([
    db.from("projects").select("id,title").eq("id",task.project_id).single(),
    db.from("project_dna").select("project_id,version,dna_json").eq("project_id",task.project_id).single(),
    db.from("conversation_messages").select("id,role,content,created_at").eq("project_id",task.project_id).order("created_at",{ascending:true})
  ]);
  if (!project || !dna || !messages) {
    await fail("Task context could not be loaded");
    return reply({task_id:task.id,status:attempts >= MAX_ATTEMPTS ? "FAILED":"PENDING"},502);
  }

  const sourceId = task.payload_json?.message_id;
  if (!(messages as any[]).some((m) => m.id === sourceId)) {
    await fail("Source conversation message not found");
    return reply({task_id:task.id,status:attempts >= MAX_ATTEMPTS ? "FAILED":"PENDING"},422);
  }

  try {
    const endpoint = aiBaseUrl.replace(/\/$/,"").endsWith("/chat/completions")
      ? aiBaseUrl.replace(/\/$/,"") : aiBaseUrl.replace(/\/$/,"") + "/chat/completions";
    const response = await fetch(endpoint,{method:"POST",headers:{
      Authorization:`Bearer ${aiKey}`,"Content-Type":"application/json"
    },body:JSON.stringify({model,messages:[
      {role:"system",content:"Você é o assistente do ThinkNest. Preserve a autoridade humana e não invente fatos."},
      {role:"system",content:`Project: ${project.title}\nProject DNA:\n${JSON.stringify(dna.dna_json)}`},
      ...(messages as any[]).map((m)=>({role:m.role,content:m.content}))
    ]})});
    const result = await response.json().catch(()=>null);
    if (!response.ok) throw new Error(`AI provider HTTP ${response.status}: ${JSON.stringify(result)}`);
    const content = result?.choices?.[0]?.message?.content;
    if (typeof content !== "string" || !content.trim()) throw new Error("AI provider returned an empty response");

    const messageId = `ai-task-${task.id}`;
    const {error:messageError} = await db.from("conversation_messages").upsert({
      id:messageId,project_id:task.project_id,role:"assistant",content,
      created_at:new Date().toISOString(),updated_at:new Date().toISOString(),
      provider_id:"cloud-ai",model,is_pending:false
    });
    if (messageError) throw messageError;

    await db.from("ai_tasks").update({status:"COMPLETED",last_error:null,updated_at:new Date().toISOString()}).eq("id",task.id);
    return reply({task_id:task.id,status:"COMPLETED",message_id:messageId});
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    await fail(message);
    return reply({task_id:task.id,status:attempts >= MAX_ATTEMPTS ? "FAILED":"PENDING",error:message},503);
  }
});