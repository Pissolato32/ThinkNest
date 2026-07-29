# ThinkNest Extensible Plugin Architecture (ADR-0025)

**Version:** 2.0  
**Status:** Approved  
**Normative ADR:** ADR-0025 (Plugin Architecture)

---

## 1. Ecosystem Plugins & Extensibility

In accordance with **ADR-0025**, ThinkNest provides a sandboxed Plugin Architecture to integrate incubations with external productivity suites:

```
┌────────────────────────────────────────────────────────┐
│               ThinkNest Core Engine                    │
└──────────────────────────┬─────────────────────────────┘
                           │ Sandboxed SDK Hooks (ADR-0025)
                           ▼
┌────────────────────────────────────────────────────────┐
│                   Plugin Ecosystem                     │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌──────┐ │
│  │    Jira    │ │   Notion   │ │   GitHub   │ │Figma │ │
│  └────────────┘ └────────────┘ └────────────┘ └──────┘ │
│  ┌────────────┐ ┌────────────┐                         │
│  │   Linear   │ │   Slack    │                         │
│  └────────────┘ └────────────┘                         │
└────────────────────────────────────────────────────────┘
```

---

## 2. Supported Extension Points

- **Export Profile Extensions:** Custom export formatters (e.g. Jira Issue XML, Notion Page Blocks, Figma Tokens).
- **Import Integrations:** Import existing board cards or document outlines directly into Quick Capture.
- **Event Listeners:** Subscribe to `SnapshotCreatedEvent` or `MaturityChangedEvent` to trigger external webhooks.
