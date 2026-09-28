import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";
import { executeAiTask } from "../_shared/ai_task.ts";

const url = Deno.env.get("SUPABASE_URL")!;
const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
const aiBaseUrl = Deno.env.get("THINKNEST_AI_BASE_URL");
const aiKey = Deno.env.get("THINKNEST_AI_API_KEY");
const model = Deno.env.get("THINKNEST_AI_MODEL") ?? "default";
const workerSecret = Deno.env.get("THINKNEST_AI_WORKER_SECRET");
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, x-client-info, content-type",
};

const reply = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply({ error: "Method not allowed" }, 405);
  if (!aiBaseUrl || !aiKey) return reply({ error: "Cloud AI provider is not configured" }, 503);

  const internalKey = req.headers.get("apikey");
  const isInternal = Boolean(
    workerSecret && internalKey && internalKey === workerSecret,
  );
  let db: SupabaseClient;
  let isAuthenticatedUser = false;

  if (isInternal) {
    if (!serviceRoleKey) {
      return reply({ error: "Supabase service credentials are not configured" }, 503);
    }
    db = createClient(url, serviceRoleKey);
  } else {
    const auth = req.headers.get("Authorization");
    if (!auth?.startsWith("Bearer ")) {
      return reply({ error: "Authentication required" }, 401);
    }
    db = createClient(url, anonKey, {
      global: { headers: { Authorization: auth } },
    });
    const {
      data: { user },
    } = await db.auth.getUser();
    if (!user) return reply({ error: "Invalid authentication" }, 401);
    isAuthenticatedUser = true;
  }

  const body = (await req.json().catch(() => null)) as {
    task_id?: string;
  } | null;
  if (!body?.task_id) return reply({ error: "task_id is required" }, 400);

  if (isAuthenticatedUser) {
    const { data: ownedTask } = await db
      .from("ai_tasks")
      .select("id")
      .eq("id", body.task_id)
      .single();
    if (!ownedTask) return reply({ error: "AI Task not found" }, 404);
  }

  const result = await executeAiTask(db, body.task_id, aiBaseUrl, aiKey, model);
  const status =
    result.status === "COMPLETED"
      ? 200
      : result.status === "RUNNING"
        ? 200
        : result.status === "FAILED"
          ? 422
          : 503;
  return reply({ task_id: body.task_id, ...result }, status);
});
