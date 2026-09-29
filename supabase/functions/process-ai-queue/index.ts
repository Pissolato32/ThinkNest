import { createAdminClient, executeAiTask } from "./ai_task.ts";
import { logError, logEvent } from "./observability.ts";

const aiBaseUrl = Deno.env.get("THINKNEST_AI_BASE_URL");
const aiKey = Deno.env.get("THINKNEST_AI_API_KEY");
const sttBaseUrl = Deno.env.get("THINKNEST_STT_BASE_URL");
const sttKey = Deno.env.get("THINKNEST_STT_API_KEY");
const model = Deno.env.get("THINKNEST_AI_MODEL") ?? "default";
const workerSecret = Deno.env.get("THINKNEST_AI_WORKER_SECRET");
const batchSize = 10;
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "apikey, content-type",
};

const reply = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply({ error: "Method not allowed" }, 405);
  if (!workerSecret || req.headers.get("apikey") !== workerSecret) {
    return reply({ error: "Authentication required" }, 401);
  }
  if ((!aiBaseUrl || !aiKey) && (!sttBaseUrl || !sttKey)) {
    return reply({ error: "Cloud AI/STT provider is not configured" }, 503);
  }

  try {
    const startedAt = Date.now();
    logEvent("ai_queue.started", { batch_size: batchSize });
    const db = createAdminClient();
    const { data: tasks, error } = await db
      .from("ai_tasks")
      .select("id")
      .eq("status", "PENDING")
      .lt("attempts", 3)
      .order("created_at", { ascending: true })
      .limit(batchSize);
    if (error) {
      logError("ai_queue.load_failed", { batch_size: batchSize });
      return reply({ error: error.message }, 500);
    }

    const results = [];
    for (const task of tasks ?? []) {
      results.push({
        task_id: task.id,
        ...(await executeAiTask(
          db,
          task.id,
          aiBaseUrl ?? sttBaseUrl!,
          aiKey ?? sttKey!,
          model,
        )),
      });
    }
    logEvent("ai_queue.completed", { processed: results.length, duration_ms: Date.now() - startedAt });
    return reply({ processed: results.length, results });
  } catch (error) {
    logError("ai_queue.failed");
    return reply(
      { error: error instanceof Error ? error.message : String(error) },
      500,
    );
  }
});
