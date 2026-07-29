# ThinkNest Home Screen Specification (`SCR_001_HOME`)

**Version:** 1.0  
**Status:** Approved  
**Screen Component:** Home / Quick Capture Hub

---

## 1. UI Blueprint & Components Layout

```
┌────────────────────────────────────────────────────────┐
│  ThinkNest                       [Search] [Settings]   │
├────────────────────────────────────────────────────────┤
│ ┌────────────────────────────────────────────────────┐ │
│ │ "What came to your mind?"                          │ │
│ │ [TextInput]               [🎙️ Voice] [📷 Snap] [▶]│ │
│ └────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────┤
│ PINNED INCUBATIONS                                     │
│ ┌───────────────────────┐ ┌──────────────────────────┐ │
│ │ 🚀 ThinkNest Mobile   │ │ 🎨 Design System v2      │ │
│ │ [Structured]  2h ago  │ │ [Exploring]    1d ago    │ │
│ └───────────────────────┘ └──────────────────────────┘ │
├────────────────────────────────────────────────────────┤
│ RECENT PROJECTS                                        │
│ ┌────────────────────────────────────────────────────┐ │
│ │ 📦 Autonomous AI Agent Platform                     │ │
│ │ Maturity: [Implementation Ready]  • 4 Docs Generated│ │
│ └────────────────────────────────────────────────────┘ │
│ ┌────────────────────────────────────────────────────┐ │
│ │ 💡 Voice-First Fitness Coach                        │ │
│ │ Maturity: [Captured]              • 1 Note Taken   │ │
│ └────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

---

## 2. Interaction Specifications

- **Sticky Quick Capture Input:** Located top center. Tapping input activates keyboard immediately with smooth upward push.
- **Voice Mic Button:** Long press initiates speech-to-text recording mode with pulsing waveform visualization.
- **Card Tap Action:** Tapping any project card opens `SCR_002_PROJECT_MAIN`.
- **Swipe Actions:** Swiping left on a project card reveals `[Archive]` and `[Delete]` action buttons.
