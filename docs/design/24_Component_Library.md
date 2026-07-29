# ThinkNest Mobile Component Library Specification

**Version:** 1.0  
**Status:** Approved  
**UI Tokens & Design Assets:** React Native / Mobile UI Components

---

## 1. Core Component Inventory

### Atomic Inputs
- **`QuickCaptureBar`:** Floating input container with auto-expanding text input, audio mic button with pulsing animation, and media attachment menu.
- **`VoiceRecordOverlay`:** Full-screen translucent sheet displaying real-time audio waveform visualizer and cancel/done controls.
- **`PrimaryButton` & `SecondaryButton`:** Haptic-enabled buttons supporting loading states, icons, and gradient fill options.

### Project Cards & Badges
- **`ProjectCard`:** Elevate-on-touch container displaying Project Title, Category Tag, Maturity Pill, and last modified timestamp.
- **`MaturityBadge`:** Colored status pill (`Captured`: Gray, `Exploring`: Blue, `Structured`: Amber, `Implementation Ready`: Emerald Green).
- **`SpecialistAvatar`:** Circular badge with domain icon (Architecture, Product, UX) indicating active AI Specialist context.

### Message & Document Renderers
- **`ChatMessageBubble`:** Markdown-rendered stream bubble with support for embedded suggestion pills and inline action cards.
- **`MarkdownViewer`:** Native-accelerated Markdown renderer supporting code blocks with copy action, mermaid diagrams, and table formatting.
