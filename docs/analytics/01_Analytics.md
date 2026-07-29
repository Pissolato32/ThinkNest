# ThinkNest Mobile Analytics & Privacy Specification

**Version:** 1.0  
**Status:** Approved  
**Module:** Analytics Subsystem

---

## 1. Privacy-Preserving Event Metrics

- **Zero Content Collection:** Idea text, project titles, transcripts, and document contents are **NEVER** sent to analytics services.
- **Tracked Anonymized Telemetry:**
  - `event_project_captured`: Frequency of Quick Capture usage (count, input type: voice vs text).
  - `event_grillme_turns`: Number of turns taken in Grill-me session before document generation.
  - `event_document_generated`: Type of document synthesized (PRD, Architecture, Canvas).
  - `event_implementation_pack_exported`: Export format chosen.
- **Provider:** Privacy-compliant telemetry via Mixpanel / PostHog with client-side anonymization.
