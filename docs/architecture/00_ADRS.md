# ThinkNest Architecture Decision Records (ADRs 0001 - 0028)

**Status:** FINAL & AUTHORITATIVE CONSTITUTION  
**Scope:** Complete Architectural Constitution for ThinkNest Incubation Platform

---

## Index of ADRs

- [ADR-0001 — Project DNA as the Single Source of Truth](#adr-0001--project-dna-as-the-single-source-of-truth)
- [ADR-0002 — Offline-First Architecture](#adr-0002--offline-first-architecture)
- [ADR-0003 — Local Database is the Primary Runtime Database](#adr-0003--local-database-is-the-primary-runtime-database)
- [ADR-0004 — Flutter Cross-Platform Architecture](#adr-0004--flutter-cross-platform-architecture)
- [ADR-0005 — Local Persistence Strategy](#adr-0005--local-persistence-strategy)
- [ADR-0006 — Cloud Backend](#adr-0006--cloud-backend)
- [ADR-0007 — Voice Capture Pipeline](#adr-0007--voice-capture-pipeline)
- [ADR-0008 — AI Task Queue](#adr-0008--ai-task-queue)
- [ADR-0009 — AI Features While Offline](#adr-0009--ai-features-while-offline)
- [ADR-0010 — Local AI Strategy](#adr-0010--local-ai-strategy)
- [ADR-0011 — Implementation Pack Builder](#adr-0011--implementation-pack-builder)
- [ADR-0012 — Export Profiles](#adr-0012--export-profiles)
- [ADR-0013 — Immutable Implementation Packs](#adr-0013--immutable-implementation-packs)
- [ADR-0014 — AI Orchestrator Ownership](#adr-0014--ai-orchestrator-ownership)
- [ADR-0015 — Project Philosophy](#adr-0015--project-philosophy)
- [ADR-0016 — AI Provider Abstraction](#adr-0016--ai-provider-abstraction)
- [ADR-0017 — Domain-Driven Architecture](#adr-0017--domain-driven-architecture)
- [ADR-0018 — Event-Driven Internal Architecture](#adr-0018--event-driven-internal-architecture)
- [ADR-0019 — Snapshot Immutability](#adr-0019--snapshot-immutability)
- [ADR-0020 — Document Lifecycle](#adr-0020--document-lifecycle)
- [ADR-0021 — AI Confidence Model](#adr-0021--ai-confidence-model)
- [ADR-0022 — AI Specialist Framework](#adr-0022--ai-specialist-framework)
- [ADR-0023 — Context Compression](#adr-0023--context-compression)
- [ADR-0024 — AI Cost Governance](#adr-0024--ai-cost-governance)
- [ADR-0025 — Plugin Architecture](#adr-0025--plugin-architecture)
- [ADR-0026 — Security by Design](#adr-0026--security-by-design)
- [ADR-0027 — AI Explainability](#adr-0027--ai-explainability)
- [ADR-0028 — Human Authority](#adr-0028--human-authority)

---

# ADR-0001 — Project DNA as the Single Source of Truth

Project DNA is the canonical representation of every project.
Conversation history is transient context only.
Generated documents are immutable artifacts derived from the Project DNA.
Every AI interaction must load and update the Project DNA rather than relying on the full conversation history.

Project DNA is provider-neutral and represents the semantic state of the project.

---

# ADR-0002 — Offline-First Architecture

ThinkNest is an Offline-First application.
The application must remain fully functional without an Internet connection, except for AI-powered capabilities.
Users must always be able to create, edit, browse, organize, attach files, and search locally.

---

# ADR-0003 — Local Database is the Primary Runtime Database

The local database is always the source of truth for the user interface.
UI ──► Local Database ──► Repository Layer ──► Sync Engine ──► Cloud.
The application must never render project data directly from the cloud backend.

---

# ADR-0004 — Flutter Cross-Platform Architecture

Flutter (Dart) is the primary implementation framework.
Primary targets: Android & Web. Secondary target: iOS.
Maximum code sharing across all supported platforms.

---

# ADR-0005 — Local Persistence Strategy

Drift shall be used as the persistence layer.
Android: SQLite. Web: SQLite WASM with OPFS (transparent fallback to IndexedDB).
Database schema, migrations, repositories, and domain models remain identical across platforms.

---

# ADR-0006 — Cloud Backend

Supabase is the primary cloud backend for V1 (PostgreSQL, Auth, Storage, Edge Functions).
Cloud services must remain replaceable through repository abstractions.

---

# ADR-0007 — Voice Capture Pipeline

Voice capture prioritizes speed:
1. Record audio locally.
2. Immediate on-device speech recognition.
3. Create project instantly.
4. If online, upload temporary audio asynchronously for Whisper refinement.
5. Update Project DNA & Snapshot only if refined version significantly improves the original.
6. Auto-delete temporary audio unless explicitly retained.

---

# ADR-0008 — AI Task Queue

AI requests shall never fail because the device is offline.
User Action ──► Local AI Task ──► Persistent Queue ──► Sync ──► Orchestrator ──► Artifact ──► Snapshot ──► Notification.
Queued AI tasks survive application restarts.

---

# ADR-0009 — AI Features While Offline

AI actions always remain visible and invokable ("Pending – Waiting for Connection").
Executing pending tasks occurs automatically upon reconnection without blocking the user.

---

# ADR-0010 — Local AI Strategy

Offline AI is NOT part of Version 1.
When offline, project management features remain available, and AI tasks are queued. Future versions may introduce local SLM support (ExecuTorch).

---

# ADR-0011 — Implementation Pack Builder

Implementation Packs are generated 100% on the client through a dedicated Implementation Pack Builder using Dart (`archive`). Cloud services are never required for packaging.

---

# ADR-0012 — Export Profiles

Pluggable export architecture supporting multiple targets (Generic, Cursor, Claude Code, Codex, OpenHands, Markdown, PDF, HTML) while preserving Project DNA.

---

# ADR-0013 — Immutable Implementation Packs

Every generated Implementation Pack represents an immutable project release with Export ID, Version Number, Timestamp, Manifest, and File Hashes.

---

# ADR-0014 — AI Orchestrator Ownership

Users interact via conversation; the AI Orchestrator is solely responsible for updating Project DNA.
Whenever confidence is insufficient, the AI must ask the user before modifying Project DNA.

---

# ADR-0015 — Project Philosophy

ThinkNest is an AI-powered Project Incubation Platform that transforms ideas into implementation-ready projects through progressive refinement while preserving human ownership.

---

# ADR-0016 — AI Provider Abstraction

The AI Orchestrator communicates exclusively through a Provider Abstraction Layer (PAL) handling request/response normalization, auth, retries, cost/token accounting, and fallback routing.

---

# ADR-0017 — Domain-Driven Architecture

ThinkNest shall follow a Domain-Driven Design (DDD) architecture organized around core business domains:
- **Project**
- **Project DNA**
- **Conversation**
- **AI Task**
- **Document**
- **Export**
- **Attachment**
- **User**
- **Workspace**
- **Synchronization**

Infrastructure components shall never contain business rules. Business logic belongs exclusively to the Domain layer.

---

# ADR-0018 — Event-Driven Internal Architecture

Internal components communicate asynchronously via an internal Event Bus:

```
ProjectCreated ──► DNAUpdated ──► SnapshotCreated ──► SearchIndexed ──► AnalyticsUpdated ──► SyncQueued
```

Decouples services completely and eliminates synchronous cross-domain locks.

---

# ADR-0019 — Snapshot Immutability

Snapshots are immutable representations of project state at a specific point in time.
- Every meaningful project modification creates a new Snapshot.
- Snapshots cannot be edited once created.
- Snapshots may be restored to revert state or compared to inspect project evolution.
- Snapshots form the complete immutable project timeline.

---

# ADR-0020 — Document Lifecycle

All generated documents follow a strict, deterministic lifecycle state machine:

```
Draft ──► Generated ──► User Reviewed ──► Approved ──► Archived
```

Prevents unverified AI content from polluting production handoff specifications.

---

# ADR-0021 — AI Confidence Model

To eliminate unwanted AI modifications, every AI inference is evaluated against a confidence threshold:

- **Confidence > 95%:** Automatically update Project DNA.
- **Confidence 80% – 95%:** Present as a suggestion card to the user for one-tap approval.
- **Confidence < 80%:** Ask the user a clarifying question before mutating state.

---

# ADR-0022 — AI Specialist Framework

Specialized AI personas operate within a coordinated, non-conflicting multi-step pipeline:

```
General AI ──► Planning ──► Architecture ──► Business ──► Research ──► Marketing ──► Finance ──► Writing ──► Synthesis Merge
```

Prevents overlapping or contradictory domain advice.

---

# ADR-0023 — Context Compression

To prevent token inflation over long-term incubation, the AI Engine enforces progressive context compression:

```
Raw Conversation ──► Summaries ──► Fact Extraction ──► Decision Locking ──► Project DNA ──► Dynamic Compression ──► Provider Payload
```

Ensures project context context window stays under 1,500 tokens regardless of project age.

---

# ADR-0024 — AI Cost Governance

The system enforces intelligent cost & model routing policies based on task complexity:
- **Simple Queries / Quick Capture:** Low-cost models (GPT-4o-mini / Claude 3.5 Haiku).
- **Architecture & PRD Generation:** High-reasoning models (Claude 3.5 Sonnet / GPT-4o / o3-mini).
- **Summarization & Fact Extraction:** Fast throughput models (Gemini 1.5 Flash).
- **Export Package Formatting:** Deterministic structured output models.

Enforces per-tier token budgets, response caching, and cost accounting.

---

# ADR-0025 — Plugin Architecture

ThinkNest provides an extensible Plugin Architecture allowing integrations with external tools:
- **Jira, Notion, GitHub, Figma, Linear, Slack**

Plugins extend export profiles, asset importers, and event notifications through sandboxed SDK hooks.

---

# ADR-0026 — Security by Design

Security is an architectural foundation enforcing:
- **Zero Trust Model**
- **End-to-End Encryption (AES-256 for local SQLite via SQLCipher)**
- **Hardware-Backed Key Vault (Keychain / Keystore)**
- **Automatic Encryption Key Rotation**
- **Least Privilege Access Control**
- **Immutable Audit Logging for state changes**

---

# ADR-0027 — AI Explainability

Whenever the AI performs an important action (e.g. updating DNA, advancing project maturity, or generating an artifact), it MUST provide a human-readable explanation:

Example:
> *"Project maturity increased to **Structured** because:  
> ✓ Product Requirements (PRD) completed  
> ✓ Key technical risks identified  
> ✓ Technical stack locked (Flutter + Supabase)  
> ✓ Open questions reduced from 5 to 1"*

Builds user confidence and transparency.

---

# ADR-0028 — Human Authority

The human creator is ALWAYS the final authority over the project:
- The user owns the project and all intellectual property.
- The AI never makes irreversible decisions without human consent.
- Every AI suggestion, document, or DNA edit can be rejected or reverted.
- Accepted human decisions can NEVER be rewritten by the AI without explicit confirmation.
