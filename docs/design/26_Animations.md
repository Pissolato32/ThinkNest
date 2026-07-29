# ThinkNest Animation & Micro-Interactions Specification

**Version:** 1.0  
**Status:** Approved  
**Engine:** React Native Reanimated 3 / Native Driver

---

## 1. Principles & Motion Specs

- **Spring Dynamics:** Card press and tab transitions use soft spring physics (`mass: 1`, `stiffness: 120`, `damping: 14`).
- **Quick Capture Transition:** Tapping input expands card from bottom with 250ms cubic-bezier transition.
- **Waveform Animation:** Voice recording mic renders 60fps canvas waveform responding to audio level inputs.
