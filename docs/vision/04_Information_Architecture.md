# ThinkNest Information Architecture

**Version:** 1.0  
**Status:** Approved  
**Platform Scope:** Mobile (iOS / Android)

---

## 1. Architectural Philosophy

ThinkNest is strict in its conceptual hierarchy: **Everything belongs to a Project.** There are no floating notes, standalone conversations, or detached documents.

```
                   ┌──────────────────────────────────┐
                   │            ThinkNest             │
                   └──────────────────────────────────┘
                                     │
      ┌──────────────────────────────┼──────────────────────────────┐
      │                              │                              │
┌───────────┐                  ┌───────────┐                  ┌───────────┐
│   Home    │                  │  Search   │                  │ Settings  │
└───────────┘                  └───────────┘                  └───────────┘
      │                                                             │
┌───────────┐                                                 ┌───────────┐
│  Project  │◄────────────────────────────────────────────────┤  Premium  │
└───────────┘                                                 └───────────┘
      │
      ├── Overview & DNA Snapshot
      ├── Conversation (Grill-me & Specialists)
      ├── Generated Documents (PRD, Specs, Outlines)
      ├── Attachments (Voice, Images, Files)
      ├── Snapshots (Version History)
      └── Implementation Pack (Export Bundle)
```

---

## 2. Main Screen Structural Mapping

### Home Screen Hierarchy
1. **Quick Capture Bar (Top/Sticky Priority):** Text field, Microphone voice trigger, Camera snap, File upload.
2. **Active Project Grid / Feed:** Cards showing project title, maturity status badge, last updated timestamp, and key tags.
3. **Pinned Projects Container:** Carousels for quick access to high-priority incubations.
4. **Archive Access Drawer:** Collapsible view of stashed or completed incubations.

### Project Workspace Hierarchy
- **Header:** Title edit, Maturity Badge (`Captured` | `Exploring` | `Structured` | `Implementation Ready`), AI DNA Health indicator, Quick Export Action.
- **Tabbed Layout (Max Depth: 3 Levels):**
  - **Tab 1: Overview** (DNA Radar, Summary, Key Milestones)
  - **Tab 2: Conversation** (Chat interface with Grill-me Engine & contextual Specialist badges)
  - **Tab 3: Documents** (List of generated Markdown/JSON specs with inline viewer/editor)
  - **Tab 4: Assets** (Media attachments, reference links, raw transcripts)
  - **Tab 5: History & Snapshots** (Timeline of saved project states)

---

## 3. Entity Relationship & Data Ownership

```
[ User ] (1)
   │
   └─── (N) [ Project ]
               │
               ├── (1)   [ Project DNA ]
               ├── (N)   [ Conversation Message ]
               ├── (N)   [ Generated Document ]
               ├── (N)   [ Media Attachment ]
               ├── (N)   [ Project Snapshot ]
               └── (0..1)[ Implementation Pack ]
```

---

## 4. Depth & Interaction Constraints

- **Maximum Navigation Depth:** strictly **3 UI Screens** (`Home` -> `Project Workspace` -> `Document View`).
- **Contextual Sheet Overlays:** Modals and bottom sheets are used exclusively for transient actions (e.g., picking a document template, configuring export parameters).
- **Navigation Flow:** Bottom navigation retains current state per tab to allow seamless switching between capture and project deep dives.
