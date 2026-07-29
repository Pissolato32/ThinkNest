# ThinkNest Implementation Pack Export Engine (ADR #9)

**Version:** 1.2  
**Status:** Approved  
**Module:** Export Subsystem / Client-Side Builder

---

## 1. Engine Purpose & Architecture

In accordance with **ADR #9**, Implementation Packs are built 100% locally on-device across all supported platforms (Android & Web) through a dedicated `ImplementationPackBuilder`. Cloud services are never required for packaging.

```
┌────────────────────────────────────────────────────────┐
│              ImplementationPackBuilder                 │
└──────────────────────────┬─────────────────────────────┘
                           │
  ┌────────────────────────┼────────────────────────┐
  ▼                        ▼                        ▼
[ Validate Project ]  [ Assemble Manifest ]   [ Resolve References ]
  │                        │                        │
  └────────────────────────┼────────────────────────┘
                           │
                           ▼
              [ Apply Export Profile ]
 (Generic | Cursor | Claude Code | Codex | OpenHands | PDF)
                           │
                           ▼
          [ Build ZIP Archive (Dart archive) ]
                           │
            ┌──────────────┴──────────────┐
            ▼                             ▼
   [ Android Share Sheet ]       [ Web Browser Download ]
```

---

## 2. Supported Export Profiles

- **`CURSOR`:** Generates `.cursorrules` + structured `.md` docs + prompt plan.
- **`CLAUDE_CODE`:** Formats prompts for Anthropic CLI / Claude Code workspace injection.
- **`CODEX` / `OPENHANDS`:** Machine-readable agent task manifest + SQL schema + JSON DNA.
- **`GENERIC_MARKDOWN`:** Standardized ZIP with PRD, Architecture, and Roadmap.
- **`DOCUMENT_PDF` / `HTML`:** Formatted readable documentation outputs.
