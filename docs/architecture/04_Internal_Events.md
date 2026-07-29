# ThinkNest Internal Event System (ADR-0018)

**Version:** 2.0
**Status:** Approved
**Normative ADR:** ADR-0018 (Event-Driven Internal Architecture)

---

## 1. Asynchronous Event Pipeline

In accordance with **ADR-0018**, ThinkNest utilizes an internal asynchronous Event Bus to completely decouple domain services and prevent synchronous cross-domain locks.

```
[ Domain Action Trigger ]
           │
           ▼
 [ ProjectCreated Event ]
           │
           ├──────────────────────────► [ DNAUpdated Event ]
           │                                   │
           ├──────────────────────────► [ SnapshotCreated Event ]
           │                                   │
           ├──────────────────────────► [ SearchIndexed Event ]
           │                                   │
           ├──────────────────────────► [ AnalyticsUpdated Event ]
           │                                   │
           └──────────────────────────► [ SyncQueued Event ]
```

---

## 2. Event Registry & Payload Contracts

- **`ProjectCreatedEvent`:** Fired when Quick Capture initializes a project card.
  - **Payload Schema:** `{ "event_id": "uuid", "timestamp": 1719619200, "project_id": "uuid", "initial_title": "string" }`
- **`DNAUpdatedEvent`:** Fired when the AI Orchestrator mutates Project DNA attributes.
  - **Payload Schema:** `{ "event_id": "uuid", "timestamp": 1719619200, "project_id": "uuid", "mutation_type": "string", "delta": "json_object" }`
- **`SnapshotCreatedEvent`:** Fired when an immutable snapshot is written to local Drift storage.
- **`SearchIndexedEvent`:** Asynchronously updates local full-text search index.
- **`AnalyticsUpdatedEvent`:** Updates client-side usage metrics without capturing content.
- **`SyncQueuedEvent`:** Enqueues delta payload into offline sync queue for Supabase replication.
