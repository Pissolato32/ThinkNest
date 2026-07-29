# ThinkNest Product Flow

**Version:** 1.3
**Status:** Approved  
**Target Platform:** Flutter (Android & Web for V1, iOS for V2)
**Changelog:** v1.3 separa explicitamente, em cada fluxo, o que executa na UI thread do que executa em isolate/worker assíncrono (a v1.2 misturava os dois níveis no mesmo grafo sem fronteira visual, achado de clareza da auditoria de 2026-07-29). Também corrige a discrepância entre a versão auditada em texto plano e a versão real do arquivo, que já usa sintaxe Mermaid graph TD.

---

## 1. Onboarding & First Launch Flow

A experiência de onboarding roda inteiramente na UI thread — não há trabalho assíncrono relevante neste fluxo.

```mermaid
graph TD
    subgraph UI["UI Thread (main isolate)"]
        Splash[Splash Screen] --> Auth[Biometric / Local Auth<br/>Silent background initialization]
        Auth --> Permissions[Permissions Primer<br/>Microphone, Camera, Storage]
        Permissions --> Demo[Quick Interactive Demo<br/>3-second capture demonstration]
        Demo --> Home[Home Screen<br/>Quick Capture Mode]
    end
```

## 2. Quick Capture & Audio Refinement Flow (ADR #7)

Este fluxo cruza três contextos de execução distintos: UI thread, um isolate local de STT, e chamadas de rede assíncronas. A v1.2 apresentava os três nós lado a lado sem indicar a fronteira — um engenheiro de frontend não conseguia saber, só pelo diagrama, onde o upload era disparado. Corrigido abaixo com subgraph por contexto de execução:

```mermaid
graph TD
    subgraph UI["UI Thread"]
        Input[User Audio Input] --> Trigger[Tap to capture]
    end

    subgraph LocalIsolate["Local STT Isolate (speech_to_text package)"]
        Trigger --> LocalSTT[Instant Local STT]
        LocalSTT --> ProjectCard[Project Card Created<br/>&lt; 100ms, back on UI thread]
        LocalSTT --> SaveTemp[Save Temporary Audio File .m4a/.wav]
    end

    subgraph Async["Async Task Queue (background, non-blocking)"]
        SaveTemp --> NetworkCheck{Network Available?}
        NetworkCheck -- YES --> Upload[Upload to Supabase Storage]
        Upload --> Whisper[Whisper Cloud Refinement]
        Whisper --> ConfidenceCheck[Orchestrator Confidence Check]
        ConfidenceCheck --> ImproveCheck{Improvement > Threshold?}
        ImproveCheck -- YES --> Mutate[Mutate DNA & Snapshot]
        ImproveCheck -- NO --> Keep[Keep Original]
        Mutate --> DeleteTemp[Auto-Delete Temp Audio File]
        Keep --> DeleteTemp
        NetworkCheck -- NO --> RetainLocal[Retain Local STT Transcript<br/>Task queued until connection restored]
    end

    ProjectCard -.UI already updated, independent of Async lane.-> UserContinues[User continues working]
```

**Contrato explícito por camada:**

*   **UI Thread:** apenas captura o toque/áudio e renderiza o Project Card assim que o isolate local retorna (<100ms). Nunca bloqueia esperando rede.
*   **Local STT Isolate:** roda via `compute()`/isolate dedicado do pacote `speech_to_text`; não tem acesso a rede.
*   **Async Task Queue:** gerenciada pelo sync engine (ver `03_Offline_Synchronization.md`); todo o ramo de upload/Whisper/mutação de DNA é desacoplado da árvore de widgets e pode ser interrompido/retomado sem afetar a UI.

## 3. Asynchronous Offline AI Tasks Flow (ADR #8)

```mermaid
graph TD
    subgraph UI["UI Thread"]
        Trigger[User Triggers Grill-me / Doc Generation Offline] --> TaskRecord[Task Record Created:<br/>'Pending - Waiting for Connection']
        TaskRecord --> UnblockedUX[User Continues Working<br/>Unblocked UX]
    end

    subgraph Async["Async Task Queue (background)"]
        ConnectionRestored[Connectivity Restored] --> SyncEngine[Sync Engine Submits Task<br/>to AI Orchestrator]
        SyncEngine --> GenDoc[Document Generated + DNA Mutated + Snapshot Created]
    end

    UnblockedUX -.persisted locally, survives app restart.-> ConnectionRestored
    GenDoc --> Notify[UI Thread: User Notified<br/>via Local Notification]
```

**Contrato explícito por camada:** o TaskRecord é persistido no Drift local antes de qualquer tentativa de rede, garantindo que o registro sobrevive a fechamento do app; a UI nunca aguarda o SyncEngine de forma síncrona.
