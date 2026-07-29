# ThinkNest Offline Synchronization Specification

**Version:** 1.2  
**Status:** Approved  
**Engine:** Local-First Drift/SQLite Sync & Offline Task Queue

---

## 1. Web & Cross-Platform Persistence (ADR #6)

- **Primary Storage (Web):** Drift + SQLite WASM + OPFS (Origin Private File System).
- **Web Fallback:** Transparent fallback to IndexedDB through Drift if OPFS is unavailable.
- **Android Storage:** Native SQLite via Drift (`drift/native`).
- **Data Parity:** Identical SQL schemas, migrations, repositories, and domain models across Android and Web. Supabase is used exclusively for sync and cloud backup.

---

## 2. Asynchronous Offline AI Tasks Queue (ADR #8)

- **Unblocked AI UI:** AI actions (Grill-me, Generate PRD) remain 100% visible and invokable offline.
- **Persistent AI Task:** Triggering an AI feature offline creates a record in `ai_task_queue` with status `'PENDING_CONNECTIVITY'`.
- **Automatic Execution:** Upon network reconnection, the Sync Engine automatically dispatches pending tasks to Supabase Edge Functions / AI Orchestrator, updates Project DNA, creates a snapshot, and notifies the user.

```
[ App Action ] ────► [ Write Local Drift DB ]
                            │
               ┌────────────┴────────────┐
               ▼                         ▼
     [ Standard Data Sync ]    [ AI Action (Offline?) ]
               │                         │
               ▼                         ▼
      [ Queue Supabase ]        [ Insert AI Pending Task ]
                                         │
                                 (Network Restored)
                                         │
                                         ▼
                               [ Execute AI Pipeline ]
```
