# ThinkNest Mobile Accessibility (a11y) Guidelines

**Version:** 1.0  
**Status:** Approved  
**Standards:** WCAG 2.1 AA Compliance

---

## 1. Requirements & Standards

- **Screen Reader Support:** All touch targets maintain explicit `accessibilityLabel`, `accessibilityHint`, and `accessibilityRole` properties for iOS VoiceOver and Android TalkBack.
- **Minimum Touch Target:** All buttons and interactive pills enforce minimum size of **44x44 pt**.
- **Dynamic Type:** Text scaling responds gracefully to system font scale preferences up to 200%.
- **Color Contrast:** Minimum contrast ratio of 4.5:1 for body text and 3:1 for large display headers against dark/light backgrounds.
