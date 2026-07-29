# ThinkNest UX Design Principles (ADR-0027 & ADR-0028)

**Version:** 2.0  
**Status:** Approved  
**Normative ADRs:** ADR-0027 (AI Explainability) & ADR-0028 (Human Authority)

---

## 1. Human Authority Principles (ADR-0028)

- **User Ownership:** The creator owns 100% of the project and every decision.
- **No Irreversible AI Actions:** The AI never deletes, overwrites locked decisions, or changes project maturity without explicit user confirmation or 1-tap approval.
- **Rejection & Rollback:** Every AI suggestion can be rejected with a single tap.

---

## 2. AI Explainability UI Guidelines (ADR-0027)

Whenever the AI updates project state, advances maturity, or generates a document, it must display an **Explainability Summary Banner**:

```
┌────────────────────────────────────────────────────────┐
│  💡 Project Maturity Increased: [ Structured ]         │
│  - Product Requirements (PRD) completed                │
│  - System Architecture & DB Schema defined             │
│  - Technical constraints locked                        │
│  - Open uncertainties reduced from 6 to 1              │
└────────────────────────────────────────────────────────┘
```
