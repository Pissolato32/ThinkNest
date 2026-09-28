import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";

export const MAX_ATTEMPTS = 3;

export type AiTaskResult = {
  status: "COMPLETED" | "PENDING" | "FAILED" | "RUNNING";
  message_id?: string;
  error?: string;
};

export async function executeAiTask(
  db: SupabaseClient,
  taskId: string,
  aiBaseUrl: string,
  aiKey: string,
  model: string,
): Promise<AiTaskResult> {
  const { data: task, error: taskError } = await db
    .from("ai_tasks")
    .select("id,project_id,status,attempts,payload_json")
    .eq("id", taskId)
    .single();

  if (taskError || !task) return { status: "FAILED", error: "AI Task not found" };
  if (task.attempts >= MAX_ATTEMPTS) return { status: "FAILED" };
  if (task.status !== "PENDING") return { status: task.status };

  const attempts = task.attempts + 1;
  const { data: claimed, error: claimError } = await db
    .from("ai_tasks")
    .update({
      status: "RUNNING",
      attempts,
      last_error: null,
      updated_at: new Date().toISOString(),
    })
    .eq("id", task.id)
    .eq("status", "PENDING")
    .lt("attempts", MAX_ATTEMPTS)
    .select("id,project_id,status,attempts,payload_json")
    .maybeSingle();

  if (claimError) return { status: "PENDING", error: claimError.message };
  if (!claimed) return { status: "RUNNING" };

  const fail = async (error: string): Promise<AiTaskResult> => {
    const status = attempts >= MAX_ATTEMPTS ? "FAILED" : "PENDING";
    await db
      .from("ai_tasks")
      .update({
        status,
        last_error: error,
        updated_at: new Date().toISOString(),
      })
      .eq("id", task.id);
    return { status, error };
  };

  const [{ data: project }, { data: dna }, { data: messages }] = await Promise.all([
    db.from("projects").select("id,title").eq("id", task.project_id).single(),
    db
      .from("project_dna")
      .select("project_id,version,dna_json")
      .eq("project_id", task.project_id)
      .single(),
    db
      .from("conversation_messages")
      .select("id,role,content,created_at")
      .eq("project_id", task.project_id)
      .order("created_at", { ascending: true }),
  ]);

  if (!project || !dna || !messages) return fail("Task context could not be loaded");

  const sourceId = task.payload_json?.message_id;
  if (!(messages as Array<{ id: string }>).some((message) => message.id === sourceId)) {
    return fail("Source conversation message not found");
  }

  try {
    const baseUrl = aiBaseUrl.endsWith("/") ? aiBaseUrl.slice(0, -1) : aiBaseUrl;
    const endpoint = baseUrl.endsWith("/chat/completions")
      ? baseUrl
      : baseUrl + "/chat/completions";
    const response = await fetch(endpoint, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${aiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: "system",
            content: "Você é o assistente do ThinkNest. Preserve a autoridade humana e não invente fatos.",
          },
          {
            role: "system",
            content: `Project: ${project.title}\\nProject DNA:\\n${JSON.stringify(dna.dna_json)}`,
          },
          ...(messages as Array<{ role: string; content: string }>).map((message) => ({
            role: message.role,
            content: message.content,
          })),
        ],
      }),
    });
    const result = await response.json().catch(() => null);
    if (!response.ok) {
      throw new Error(`AI provider HTTP ${response.status}: ${JSON.stringify(result)}`);
    }
    const content = result?.choices?.[0]?.message?.content;
    if (typeof content !== "string" || !content.trim()) {
      throw new Error("AI provider returned an empty response");
    }

    const messageId = `ai-task-${task.id}`;
    const now = new Date().toISOString();
    const { error: messageError } = await db.from("conversation_messages").upsert({
      id: messageId,
      project_id: task.project_id,
      role: "assistant",
      content,
      created_at: now,
      updated_at: now,
      provider_id: "cloud-ai",
      model,
      is_pending: false,
    });
    if (messageError) throw messageError;

    const { error: completionError } = await db
      .from("ai_tasks")
      .update({
        status: "COMPLETED",
        last_error: null,
        updated_at: now,
      })
      .eq("id", task.id);
    if (completionError) throw completionError;

    return { status: "COMPLETED", message_id: messageId };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    return fail(message);
  }
}

export function createAdminClient(): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !serviceRoleKey) {
    throw new Error("Supabase service credentials are not configured");
  }
  return createClient(url, serviceRoleKey);
}
