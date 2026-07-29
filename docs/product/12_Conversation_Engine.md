# ThinkNest Conversation Engine Specification

**Version:** 1.0  
**Status:** Approved  
**Module:** Product / Core Engine

---

## 1. Engine Overview

The **Conversation Engine** manages real-time, stateful dialogue between the user and the ThinkNest AI platform. Designed for mobile-first interaction, it supports low-latency streaming responses, voice transcript processing, and progressive artifact triggering.

---

## 2. Conversation Architecture & Pipeline

```
[ User Input (Voice/Text) ]
           │
           ▼
[ Speech-to-Text Pipeline (Whisper / Native OS Speech) ]
           │
           ▼
[ Input Sanitization & Token Estimation ]
           │
           ▼
[ Context Assembler ] ─── Inject: Project DNA + Last 10 Messages + Document Summaries
           │
           ▼
[ LLM Provider Gateway (Streaming Response SSE) ]
           │
           ▼
[ Real-time Message Stream Renderer (Mobile UI) ]
           │
           ▼
[ Post-Response Mutation Trigger ]
           ├── Extract Updated Decisions & Intent
           ├── Update Project DNA Async
           └── Evaluate Artifact Generation Triggers
```

---

## 3. Key Interaction Rules

1. **No Cold Greetings:** Conversations within a project skip pleasantries and launch directly into value-add analysis or structured questioning.
2. **One-Question Limit:** To avoid cognitive overload on mobile, the Grill-me mode asks **exactly one targeted question** per turn.
3. **Action Cards:** When the conversation hits a milestone, the engine renders interactive UI action cards directly in the message stream (e.g., `[ Generate PRD ]`, `[ Lock Tech Stack ]`, `[ Save Snapshot ]`).
4. **Offline Queueing:** If network connection is lost, messages are saved in local SQLite queue and dispatched automatically upon reconnection.
