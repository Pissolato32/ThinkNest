# ThinkNest Product Flow

**Version:** 1.2  
**Status:** Approved  
**Target Platform:** Flutter (Android & Web for V1, iOS for V2)

---

## 1. Onboarding & First Launch Flow

The onboarding experience prioritizes immediate value delivery with zero-friction entry points.

```mermaid
graph TD
    Splash[Splash Screen] --> Auth[Biometric / Local Auth<br/>Silent background initialization]
    Auth --> Permissions[Permissions Primer<br/>Microphone, Camera, Storage]
    Permissions --> Demo[Quick Interactive Demo<br/>3-second capture demonstration]
    Demo --> Home[Home Screen<br/>Quick Capture Mode]
```

---

## 2. Quick Capture & Audio Refinement Flow (ADR #7)

Idea capture is the foundational entry point of ThinkNest.

```mermaid
graph TD
    Input[User Audio Input] --> LocalSTT[Instant Local STT speech_to_text]
    LocalSTT -- Project Card Created Instantly < 100ms --> SaveTemp[Save Temporary Audio File .m4a/.wav]
    SaveTemp --> NetworkCheck{Network Available?}

    NetworkCheck -- YES --> Upload[Async Upload to Supabase Storage]
    Upload --> Whisper[Whisper Cloud Refinement]
    Whisper --> ConfidenceCheck[Orchestrator Confidence Check]

    ConfidenceCheck --> ImproveCheck{Improvement > Threshold?}
    ImproveCheck -- YES --> Mutate[Mutate DNA & Snapshot]
    ImproveCheck -- NO --> Keep[Keep Original]

    Mutate --> DeleteTemp[Auto-Delete Temp Audio File]
    Keep --> DeleteTemp

    NetworkCheck -- NO --> RetainLocal[Retain Local STT Transcript<br/>Upload Queued until Connection]
```

---

## 3. Asynchronous Offline AI Tasks Flow (ADR #8)

```mermaid
graph TD
    Trigger[User Triggers Grill-me / Doc Generation Offline] --> TaskRecord[App Creates AI Task Record: 'Pending - Waiting for Connection']
    TaskRecord --> UnblockedUX[User Continues Working Normally Unblocked UX]
    UnblockedUX --> ConnectionRestored[Connectivity Restored]
    ConnectionRestored --> SyncEngine[Sync Engine Submits Task to AI Orchestrator]
    SyncEngine --> GenDoc[Document Generated + DNA Mutated + Snapshot Created]
    GenDoc --> Notify[User Notified via Local Notification]
```
