# ThinkNest Project DNA Specification

**Version:** 1.2  
**Status:** Approved  
**Type:** Core Engine Specification / Architectural Decision #5

---

## 1. Architectural Decision #5: Single Source of Truth

- **Project DNA is the Single Source of Truth:** The Project DNA JSON tree represents the authoritative, persistent knowledge state of a project.
- **Transient Conversation History:** Conversation messages are treated as transient inputs used to elicit facts and choices; they are not the primary long-term memory.
- **Immutable Generated Documents:** Generated documents (PRDs, Architecture Specs, Roadmaps) are versioned, immutable artifacts created at specific milestones.
- **AI Context Ingestion:** Project DNA is continuously updated by the AI Orchestrator after every interaction turn and serves as the primary context payload sent to AI providers.
- **Strategic Impact:** Guarantees LLM provider independence, minimizes token consumption (<1,500 tokens context window), and prevents drift or degradation in long-term conversation sessions.

---

## 2. Project DNA Schema Definition

```json
{
  "project_id": "uuid-v4-string",
  "version": 1,
  "last_updated": "2026-07-28T23:28:00Z",
  "identity": {
    "title": "ThinkNest Mobile",
    "one_liner": "AI-powered mobile project incubator",
    "category": "Mobile Application / Developer Tools",
    "maturity": "Structured"
  },
  "core_pillars": {
    "problem_statement": "Ideas disappear because traditional note apps are passive and project tools are bureaucratic.",
    "target_audience": ["Founders", "Indie Developers", "Product Designers"],
    "value_proposition": "Transform raw ideas into implementation-ready specs in minutes."
  },
  "technical_constraints": {
    "target_platforms": ["Android", "Web", "iOS"],
    "preferred_stack": ["Flutter", "Dart", "SQLite / Drift", "Supabase Backend"],
    "offline_first": true
  },
  "key_decisions": [
    {
      "id": "dec_001",
      "topic": "Code Generation",
      "decision": "ThinkNest will NEVER generate production code; it only generates specifications.",
      "rationale": "Prevents platform bloat and preserves strict positioning as an incubator."
    },
    {
      "id": "dec_005",
      "topic": "Single Source of Truth",
      "decision": "Project DNA is the single source of truth; conversations are transient; documents are immutable artifacts.",
      "rationale": "Ensures LLM provider independence, minimizes token consumption, and maintains long-term consistency."
    }
  ],
  "open_uncertainties": [
    "Monetization model pricing tiers for high-volume local AI model users."
  ],
  "specialist_state": {
    "active_specialist": "Software Architect",
    "consulted_specialists": ["Product Manager", "UX Designer"]
  }
}
```

---

## 3. DNA Mutation & Context Rules

1. **Continuous Orchestrator Sync:** Updated asynchronously after every user answer or decision.
2. **Deterministic Token Limit:** Strict cap (<1,500 tokens) for LLM context payload efficiency.
3. **Immutability of Documents:** Document generation snapshots reference exact DNA versions.
4. **Transient History Pruning:** Historical chat turns are archived while Project DNA retains the distilled intelligence.
