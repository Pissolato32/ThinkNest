# ThinkNest AI Specialists Architecture

**Version:** 1.0  
**Status:** Approved  
**System:** Multi-Agent Orchestration Specification

---

## 1. Core Philosophy

Users interact with **a single unified AI assistant interface**. Internally, ThinkNest dynamically orchestrates domain-specific **AI Specialists** without subjecting the user to complex persona selection dropdowns or manual prompting.

---

## 2. Specialist Catalog & Domain Matrix

| Specialist Persona | Domain Expertise | Primary Output Artifacts | Trigger Conditions |
|---|---|---|---|
| **Product Manager** | Scope definition, feature prioritization, user stories | PRD, MVP Scope, User Stories | General exploration, feature brainstorming |
| **Software Architect** | System design, database modeling, API contracts | Architecture Spec, DB Schema, Tech Stack | Technical queries, infrastructure planning |
| **UX/UI Designer** | User flows, component design, interaction principles | Wireframe Spec, Screen Maps, Design Tokens | Interface discussions, screen design |
| **Business Strategist** | Value prop, pricing model, competitor analysis | Business Model Canvas, Pitch Summary | Monetization, market positioning |
| **Growth & Marketing** | Launch strategy, target audience, acquisition channels | Marketing Strategy, Content Plan | Launch prep, audience targeting |
| **Book & Content Editor** | Chapter structure, narrative arcs, tone consistency | Outline, Executive Summary | Non-software writing projects |

---

## 3. Dynamic Orchestration & Routing Engine

```
[ User Input / Conversation Context ]
                   │
                   ▼
       [ Intent Classifier Node ]
                   │
     ┌─────────────┴─────────────┐
     ▼                           ▼
[ Single Domain ]       [ Multi-Domain Needed ]
     │                           │
     ▼                           ▼
[ Dispatch to ]         [ Parallel Specialist Queries ]
[ Specialist  ]                  │
     │                           ▼
     │                  [ Synthesis Engine ]
     └─────────────┬─────────────┘
                   │
                   ▼
     [ Unified Natural Response ]
```

### Routing Rules
- **Invisible Routing:** The AI response remains natural and unified.
- **Contextual Attribution:** The AI may prefix subtle expert perspective tags when providing specialized analysis (e.g., *"From a software architecture perspective..."*).
- **Fallback:** If context is general or non-specialized, the default **Core Incubation Specialist** handles the turn.
