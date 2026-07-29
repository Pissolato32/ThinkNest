# ThinkNest AI Orchestrator Specification

**Version:** 2.0  
**Status:** Approved  
**Normative ADRs:** ADR-0014 (Orchestrator Ownership) & ADR-0022 (Specialist Framework)

---

## 1. Specialist Orchestration Pipeline (ADR-0022)

Specialized AI domain personas execute in a non-conflicting, sequential synthesis pipeline:

```
[ User Input / Task Request ]
              │
              ▼
    [ General AI Router ]
              │
              ▼
   [ Planning Specialist ] ──► (Scope & Feature Boundaries)
              │
              ▼
 [ Architecture Specialist ] ──► (Tech Stack & DB Schema)
              │
              ▼
   [ Business Specialist ] ──► (Monetization & Strategy)
              │
              ▼
   [ Research Specialist ] ──► (Market Context & Competitors)
              │
              ▼
    [ Synthesis & Merge ] ──► (Single Harmonized Response / Artifact)
```

---

## 2. Orchestrator DNA Ownership (ADR-0014)

- The AI Orchestrator alone evaluates and applies updates to Project DNA.
- Users converse naturally; the Orchestrator extracts locked decisions.
- If confidence is <80% (ADR-0021), the Orchestrator must query the user before mutating DNA.
