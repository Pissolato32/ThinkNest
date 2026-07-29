# ThinkNest Domain-Driven Model Specification (ADR-0017)

**Version:** 2.0  
**Status:** Approved  
**Normative ADR:** ADR-0017 (Domain-Driven Architecture)

---

## 1. Core Bounded Contexts & Domains

In accordance with **ADR-0017**, ThinkNest's business logic is organized strictly around business domains rather than technical infrastructure layers:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        THINKNEST DOMAIN BOUNDARY                       │
│                                                                        │
│  ┌──────────────────────┐   ┌──────────────────────┐                   │
│  │   Project Domain     │──►│  Project DNA Domain  │                   │
│  └──────────────────────┘   └──────────────────────┘                   │
│             │                           │                              │
│             ▼                           ▼                              │
│  ┌──────────────────────┐   ┌──────────────────────┐                   │
│  │ Conversation Domain  │   │   AI Task Domain     │                   │
│  └──────────────────────┘   └──────────────────────┘                   │
│             │                           │                              │
│             ▼                           ▼                              │
│  ┌──────────────────────┐   ┌──────────────────────┐                   │
│  │   Document Domain    │   │    Export Domain     │                   │
│  └──────────────────────┘   └──────────────────────┘                   │
│             │                           │                              │
│             ▼                           ▼                              │
│  ┌──────────────────────┐   ┌──────────────────────┐                   │
│  │  Attachment Domain   │   │ Synchronization Dom. │                   │
│  └──────────────────────┘   └──────────────────────┘                   │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Domain Responsibilities

1. **`Project Domain`:** Manages project lifecycle, titles, metadata, and status transitions.
2. **`Project DNA Domain`:** Single Source of Truth containing goals, locked decisions, and technical constraints.
3. **`Conversation Domain`:** Transient chat messages and user input stream processing.
4. **`AI Task Domain`:** Persistent queue of asynchronous AI generation tasks (survives app restarts).
5. **`Document Domain`:** Manages document lifecycle (`Draft` -> `Generated` -> `User Reviewed` -> `Approved` -> `Archived`).
6. **`Export Domain`:** Implementation Pack Builder and pluggable profile compilation.
7. **`Synchronization Domain`:** Local-first queueing and Supabase Cloud delta replication.
