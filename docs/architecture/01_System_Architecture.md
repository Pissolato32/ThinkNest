# ThinkNest System Architecture Specification

**Version:** 3.0  
**Status:** Approved & Normative  
**Authoritative Constitution:** [00_ADRS.md](00_ADRS.md)

---

## 1. Architectural Constitution Summary (ADRs 0001 - 0028)

ThinkNest's system architecture is strictly governed by 28 authoritative ADRs detailed in [00_ADRS.md](00_ADRS.md):

| ADR | Title | Key Architectural Principle |
|---|---|---|
| **ADR-0001** | Single Source of Truth | Project DNA is canonical; conversations are transient; docs are immutable. |
| **ADR-0002** | Offline-First Architecture | Core app functions 100% offline without network connectivity. |
| **ADR-0003** | Local Database Priority | Local DB is the primary UI source of truth; cloud is sync-only. |
| **ADR-0004** | Flutter Cross-Platform | Flutter (Dart) for Android & Web (V1), iOS (V2). |
| **ADR-0005** | Local Persistence | Drift + SQLite (Android) / SQLite WASM + OPFS (Web). |
| **ADR-0006** | Cloud Backend | Supabase (PostgreSQL, Auth, Storage, Edge Functions) behind abstractions. |
| **ADR-0007** | Voice Capture Pipeline | Immediate local STT + async Whisper cloud refinement with auto-cleanup. |
| **ADR-0008** | AI Task Queue | Persistent local queue for AI requests surviving app restarts. |
| **ADR-0009** | Offline AI Features | Unblocked UI ("Pending – Waiting for Connection") with auto-exec on reconnect. |
| **ADR-0010** | Local AI Strategy | No offline AI in V1; ExecuTorch SLM planned for V2. |
| **ADR-0011** | Implementation Pack Builder | 100% client-side packaging in Dart (`archive`). |
| **ADR-0012** | Export Profiles | Pluggable export targets (Cursor, Claude Code, Codex, OpenHands, PDF, etc.). |
| **ADR-0013** | Immutable Implementation Packs | Immutable releases with Export ID, manifest, and file hashes. |
| **ADR-0014** | AI Orchestrator Ownership | AI Orchestrator alone updates DNA; asks user when confidence < 80%. |
| **ADR-0015** | Project Philosophy | Project Incubation Platform (not notes/chatbot/coding assistant). |
| **ADR-0016** | AI Provider Abstraction | PAL handles normalization, retries, cost/token accounting, dynamic routing. |
| **ADR-0017** | Domain-Driven Architecture | Clean DDD architecture (Project, DNA, Conversation, AI Task, Document, etc.). |
| **ADR-0018** | Event-Driven Architecture | Internal Event Bus (`ProjectCreated` -> `DNAUpdated` -> `SnapshotCreated` -> ...). |
| **ADR-0019** | Snapshot Immutability | Snapshots are immutable, versioned historical points in time. |
| **ADR-0020** | Document Lifecycle | Strict state machine: `Draft` -> `Generated` -> `User Reviewed` -> `Approved` -> `Archived`. |
| **ADR-0021** | AI Confidence Model | Thresholds: >95% Auto-update; 80-95% Suggestion; <80% Ask User. |
| **ADR-0022** | Specialist Framework | Sequenced pipeline: General -> Planning -> Arch -> Biz -> Synthesis Merge. |
| **ADR-0023** | Context Compression | Pipeline: Raw -> Summary -> Facts -> Decisions -> DNA Compression (<1.5k tokens). |
| **ADR-0024** | AI Cost Governance | Dynamic task-based model routing, token budgeting, cost tracking. |
| **ADR-0025** | Plugin Architecture | Sandboxed SDK hooks for Jira, Notion, GitHub, Figma, Linear, Slack. |
| **ADR-0026** | Security by Design | Zero Trust, AES-256 SQLCipher, Hardware Key Rotation, Audit Logs. |
| **ADR-0027** | AI Explainability | Human-readable reasoning provided for all maturity & DNA modifications. |
| **ADR-0028** | Human Authority | Human creator is final authority; AI never makes irreversible decisions. |

---

## 2. Layered Domain Architecture (ADR-0017)

```
┌────────────────────────────────────────────────────────────────────────┐
│                   PRESENTATION / UI LAYER (Flutter / Riverpod)         │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   DOMAIN LAYER (Pure Business Logic - DDD)             │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌─────────────┐ │
│  │ Project Domain│ │ DNA Domain    │ │ Document Dom. │ │ AI Task Dom.│ │
│  └───────────────┘ └───────────────┘ └───────────────┘ └─────────────┘ │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Internal Event Bus (ADR-0018)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   INFRASTRUCTURE LAYER (Adapters & Plugins)            │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌─────────────┐ │
│  │ Drift SQLite  │ │ Supabase Sync │ │ Provider Abs. │ │ Plugin SDK  │ │
│  └───────────────┘ └───────────────┘ └───────────────┘ └─────────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```
