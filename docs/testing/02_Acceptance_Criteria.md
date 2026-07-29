# ThinkNest Feature Acceptance Criteria

**Version:** 1.0  
**Status:** Approved  
**QA Standards:** User Story Acceptance Criteria

---

## 1. Core Feature Criteria

### Quick Capture (`US_001`)
- **Given** the app is closed, **When** the user opens ThinkNest, **Then** the Quick Capture input is ready for text/voice entry in under 800ms.
- **Given** an input is submitted, **When** the user taps Send, **Then** a new Project Card is rendered in under 100ms and background AI title/category generation begins.

### Grill-me Exploration (`US_002`)
- **Given** a user opens a project in `Captured` status, **When** they tap Explore, **Then** the AI asks exactly ONE targeted clarification question.
- **Given** 3 exploration turns are completed, **When** sufficient structure exists, **Then** an action card offering document generation appears automatically.

### Implementation Pack Export (`US_003`)
- **Given** a project reaches `Implementation Ready`, **When** the user taps Export, **Then** a complete zip archive containing `.cursorrules`, `PROJECT_DNA.json`, and Markdown documents is handed off to the native share sheet.
