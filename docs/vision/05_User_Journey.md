# ThinkNest User Journey Map

**Version:** 1.0  
**Status:** Approved  
**Focus:** Mobile Interaction Design & Lifecycle UX

---

## 1. Persona Profiles

### Persona A: The On-the-Go Founder / Creator
- **Context:** Gets sudden ideas while driving, walking, or in meetings.
- **Pain Point:** Notes apps become graveyard folders; complex project management tools require too much setup.
- **ThinkNest Value:** Voice capture in <3s + AI Grill-me incubation that structures thoughts without manual effort.

### Persona B: The Technical Builder / Engineer
- **Context:** Has technical ideas but needs functional requirements, architecture outlines, and edge-case discovery before writing code.
- **Pain Point:** Spending hours creating boilerplate PRDs and system documentation.
- **ThinkNest Value:** Generates structured Implementation Packs exportable directly to Cursor, Claude Code, or GitHub.

---

## 2. Core User Journey Stages

```
STAGE 1: CAPTURE          STAGE 2: INCUBATION         STAGE 3: STRUCTURING       STAGE 4: HANDOFF
┌──────────────────┐      ┌──────────────────┐        ┌──────────────────┐       ┌──────────────────┐
│  Instant Voice/  │  ──> │ Interactive AI   │   ──>  │ Automated Doc    │  ──>  │ Implementation   │
│  Text Input      │      │ Grill-me Session │        │ Generation (PRD) │       │ Pack Export      │
└──────────────────┘      └──────────────────┘        └──────────────────┘       └──────────────────┘
```

---

## 3. Detailed Stage Breakdown

### Stage 1: Fast Capture (< 5 seconds)
- **User Trigger:** Sudden idea or insight.
- **Action:** Opens app (or uses iOS LockScreen Widget / Android Quick Tile), speaks or types input, hits send.
- **System Action:** Stores text/audio locally, creates Project Card with auto-generated title and DNA initialization.
- **Emotional State:** Relieved that the idea is saved.

### Stage 2: Progressive Incubation (Grill-me Session)
- **User Action:** Selects "Explore Potential".
- **System Action:** AI asks ONE pinpointed question addressing key ambiguity (e.g., target audience, technical stack constraint, business model).
- **User Action:** Answers naturally via voice response or text.
- **Emotional State:** Engaged and inspired by intelligent feedback.

### Stage 3: Structuring & Document Synthesis
- **User Action:** Requests document generation or approves AI suggestion.
- **System Action:** AI Orchestrator delegates tasks to virtual Specialists (e.g., Software Architect, Product Manager).
- **Output:** Live generation of PRD, System Architecture, and Technical Roadmap into the Project Documents tab.
- **Emotional State:** Empowered; sees vague idea transformed into solid structure.

### Stage 4: Execution Handoff (Implementation Ready)
- **User Action:** Taps "Export Implementation Pack".
- **System Action:** Formats JSON/Markdown bundle ready for LLM consumption, CLI import, or developer handoff.
- **User Outcome:** *"I know exactly what to do next."*
- **Emotional State:** Confident and ready to build.
