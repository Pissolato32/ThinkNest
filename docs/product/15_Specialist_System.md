# ThinkNest Specialist System Specification

**Version:** 1.0  
**Status:** Approved  
**Module:** Product / Specialist System

---

## 1. Overview

The **Specialist System** manages domain-tailored system prompts, evaluation criteria, and output templates for virtual advisors (Software Architect, Product Manager, UX Designer, Business Strategist, etc.).

---

## 2. Dynamic Specialist Activation Flow

```
[ Incoming Project State / Query ]
                │
                ▼
  [ Specialist Evaluator Node ]
  ├── Keyword & Intent Detection
  ├── Project Category Match
  └── Document Generation Requirements
                │
                ▼
  [ System Prompt Injection ]
  ├── Primary Role Definition
  ├── Domain Specific Constraints
  └── Target Output Format
                │
                ▼
  [ Specialist Response Generation ]
```

---

## 3. Specialist Prompt Guidelines

- **Concise & Tactical:** Specialists deliver direct actionable guidance suitable for mobile consumption.
- **Structured Outputs:** When generating reports, specialists format data using standard Markdown tables, lists, and mermaid diagram syntax.
- **No Persona Bloat:** Specialists focus purely on technical/domain output without theatrical roleplay.
