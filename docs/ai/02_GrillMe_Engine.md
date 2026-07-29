# ThinkNest Grill-me Engine Specification

**Version:** 2.0  
**Status:** Approved  
**Normative ADRs:** ADR-0021 (AI Confidence Model) & ADR-0028 (Human Authority)

---

## 1. Engine Objective

The **Grill-me Engine** is ThinkNest's signature incubation feature. It methodically reduces project uncertainty by guiding users through a zero-friction, one-question-at-a-time conversation.

---

## 2. Decision Tree & Execution Algorithm

```
[ Capture Received ]
         │
         ▼
[ Uncertainty Matrix Analysis ]
├── Is Target Audience Defined? (Yes/No)
├── Is Core Problem Clear? (Yes/No)
├── Are Technical Constraints Known? (Yes/No)
└── Is Key Value Prop Locked? (Yes/No)
         │
         ▼
[ Identify Highest Weight Ambiguity ]
         │
         ▼
[ Formulate 1 Precise Question ] ── (Mobile UX optimized, <30 words)
         │
         ▼
[ User Responds (Voice/Text) ]
         │
         ▼
[ Confidence Evaluation (ADR-0021) ]
├── Confidence > 95% ──► Mutate Project DNA Directly
├── Confidence 80-95% ──► Render UI Suggestion Card
└── Confidence < 80% ──► Ask 1 Clarifying Question
         │
         ▼
    ┌────┴──────────────────────────┐
    ▼                               ▼
[ Sufficient Data to Generate Doc? ]  [ Ambiguity Still High? ]
    │                               │
    ▼                               ▼
[ Offer Floating Action Card ]   [ Formulate Next Question ]
  "Generate PRD Now"
```

---

## 3. Stopping Criteria & Human Authority Guards (ADR-0028)

- **Human Authority Guarantee:** The user can reject any Grill-me suggestion or exit the loop at any time. Accepted decisions are never rewritten by AI.
- **Interrogation Guard:** Stop questioning as soon as sufficient structure exists to generate a core document (PRD or Architecture).
- **User Preference Override:** If the user states *"Generate doc now"* or *"Stop asking"*, immediately exit Grill-me loop and render current artifacts.
- **Maximum Consecutive Question Cap:** Never exceed **5 turns** without presenting a generated summary artifact or document preview.
