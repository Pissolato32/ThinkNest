# ThinkNest Product Flow

**Version:** 1.2  
**Status:** Approved  
**Target Platform:** Flutter (Android & Web for V1, iOS for V2)

---

## 1. Onboarding & First Launch Flow

The onboarding experience prioritizes immediate value delivery with zero-friction entry points.

```
[ Splash Screen ] 
       ↓
[ Biometric / Local Auth ] (Silent background initialization)
       ↓
[ Permissions Primer ] (Microphone, Camera, Storage)
       ↓
[ Quick Interactive Demo ] (3-second capture demonstration)
       ↓
[ Home Screen (Quick Capture Mode) ]
```

---

## 2. Quick Capture & Audio Refinement Flow (ADR #7)

Idea capture is the foundational entry point of ThinkNest.

```
[ User Audio Input ]
       ↓
[ Instant Local STT (speech_to_text) ] ── (Project Card Created Instantly < 100ms)
       ↓
[ Save Temporary Audio File (.m4a/.wav) ]
       ↓
(Network Available?)
       ├── YES ──► [ Async Upload to Supabase Storage ] ──► [ Whisper Cloud Refinement ]
       │                                                              │
       │                                               [ Orchestrator Confidence Check ]
       │                                                              │
       │                                              (Improvement > Threshold?)
       │                                                ├── YES ──► [ Mutate DNA & Snapshot ]
       │                                                └── NO  ──► [ Keep Original ]
       │                                                              │
       │                                               [ Auto-Delete Temp Audio File ]
       │
       └── NO  ──► [ Retain Local STT Transcript ] (Upload Queued until Connection)
```

---

## 3. Asynchronous Offline AI Tasks Flow (ADR #8)

```
[ User Triggers Grill-me / Doc Generation (Offline) ]
       ↓
[ App Creates AI Task Record: "Pending - Waiting for Connection" ]
       ↓
[ User Continues Working Normally (Unblocked UX) ]
       ↓
[ Connectivity Restored ]
       ↓
[ Sync Engine Submits Task to AI Orchestrator ]
       ↓
[ Document Generated + DNA Mutated + Snapshot Created ]
       ↓
[ User Notified via Local Notification ]
```
