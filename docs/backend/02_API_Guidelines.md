# ThinkNest API Guidelines & Supabase Contracts

**Version:** 1.1  
**Status:** Approved  
**Protocols:** Supabase SDK / REST / SSE / Edge Functions

---

## 1. Supabase & Edge Function Contracts

- **Base URL:** `https://[project-ref].supabase.co/functions/v1`
- **Authentication:** `Authorization: Bearer <user_jwt>` header managed by `supabase_flutter` SDK.
- **AI Streaming Endpoint:** `/ai-gateway-stream` using Server-Sent Events (`text/event-stream`).

```json
{
  "type": "https://thinknest.app/errors/offline",
  "title": "Network Unavailable",
  "status": 503,
  "detail": "AI services require internet connection in V1. Local project data remains fully functional.",
  "instance": "/functions/v1/ai-gateway-stream"
}
```
