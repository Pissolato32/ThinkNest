# ThinkNest Project Workspace Screen Specification (`SCR_002_PROJECT_MAIN`)

**Version:** 1.0  
**Status:** Approved  
**Screen Component:** Project Hub

---

## 1. Screen Layout & Navigation Tabs

```
┌────────────────────────────────────────────────────────┐
│ ← Back   Project: ThinkNest Mobile    [Export Pack] ⚙️ │
│ Status Badge: [Structured]   DNA Health: [92%]        │
├────────────────────────────────────────────────────────┤
│ [ Overview ]  [ Conversation ]  [ Documents ] [Assets] │
├────────────────────────────────────────────────────────┤
│                                                        │
│  [ ACTIVE TAB CONTENT AREA ]                          │
│                                                        │
│  - Overview: Radar chart of DNA completion, metadata  │
│  - Conversation: Active Grill-me session stream        │
│  - Documents: Generated PRDs, Architecture, Outlines   │
│  - Assets: Uploaded media, audio recordings, links     │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## 2. Dynamic Header Behaviors

- **Status Badge:** Tapping maturity badge (`Captured` -> `Exploring` -> `Structured` -> `Implementation Ready`) displays progress modal showing missing requirements.
- **Export Pack Button:** Pulsing accent color when readiness score hits 100%. Tapping launches Implementation Pack exporter modal.
