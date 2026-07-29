# ThinkNest Project DNA Engine Specification

**Version:** 1.0  
**Status:** Approved  
**Module:** Product / State Management

---

## 1. Engine Purpose

The **Project DNA Engine** is responsible for extracting, compressing, maintaining, and syncing the living state representation (Project DNA) of every project in ThinkNest.

---

## 2. Processing Pipeline

```
[ Conversation Turn / User Action ]
                 │
                 ▼
     [ Feature Extractor Node ]
     ├── Identify Locked Decisions
     ├── Detect Open Ambiguities
     ├── Recognize Tech Constraints
     └── Track Target Audience Details
                 │
                 ▼
     [ DNA Merger & Deduplicator ]
     └── Merge new facts into existing JSON DNA tree
                 │
                 ▼
     [ Schema Validator & Compression ]
     └── Ensure token length < 1500 tokens
                 │
                 ▼
     [ Local DB Commit (WatermelonDB/SQLite) ]
     └── Notify UI Observers (RxJS / State Store)
```

---

## 3. Storage & Cache Strategy

- **On-Device Storage:** SQLite database indexed by `project_id`.
- **In-Memory Cache:** LRU cache retaining DNA trees for the active and 3 most recently accessed projects to guarantee instantaneous screen renders.
- **Diff Tracking:** Every mutation stores a JSON Patch (`rfc6902`) in snapshot history for rollback and version comparison.
