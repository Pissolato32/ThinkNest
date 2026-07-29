# ThinkNest Conversation Screen Specification (`SCR_003_CONVERSATION`)

**Version:** 1.0  
**Status:** Approved  
**Screen Component:** Chat & Grill-me Stream

---

## 1. UI Blueprint

```
┌────────────────────────────────────────────────────────┐
│  AI Specialist: 🏗️ Software Architect                  │
├────────────────────────────────────────────────────────┤
│                                                        │
│ 🤖 ThinkNest AI:                                       │
│ "To design the database schema for ThinkNest Mobile,   │
│ what target offline-sync engine do you prefer?"        │
│                                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ 💡 Quick Suggestion Pills:                          │ │
│ │ [ SQLite + WatermelonDB ]  [ Realm ]  [ Supabase ] │ │
│ └────────────────────────────────────────────────────┘ │
│                                                        │
│ 👤 User:                                               │
│ "Let's go with SQLite + WatermelonDB for offline first"│
│                                                        │
│ 🤖 ThinkNest AI:                                       │
│ "Excellent decision. Decision locked in Project DNA."  │
│ ┌────────────────────────────────────────────────────┐ │
│ │ 📄 Action Card: [ Generate Architecture Spec ]      │ │
│ └────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────┤
│ [ Message Input...                        ] [🎙️] [Send] │
└────────────────────────────────────────────────────────┘
```

---

## 2. Dynamic Controls & Streaming

- **Streaming Typing Indicator:** Smooth character streaming via SSE with word-by-word fade in.
- **Suggestion Pills:** Tapping a suggestion pill automatically submits the selected text as the user response.
- **Inline Artifact Cards:** Tapping an inline action card triggers background document generation without closing the chat view.
