# ThinkNest AI Provider & Speech Integrations

**Version:** 1.1  
**Status:** Approved  
**Module:** Integrations / AI & Speech Adapters

---

## 1. Supported AI & Speech Services

| Component | Target Engine / Provider | V1 Scope | Role & Strategy |
|---|---|---|---|
| **Speech-to-Text + Capture (Primary)** | Local Device API (`stt_record`) | Active (V1) | Single microphone pipeline for realtime Android/iOS STT plus local WAV artifact. |
| **Speech Refinement** | Cloud transcription API via Supabase Edge Function | Active (V1) | Refines the local transcript from the private WAV artifact; result remains an AI Task result until a human-facing approval flow is added. |
| **Primary LLM** | Anthropic Claude 3.5 Sonnet / OpenAI GPT-4o | Active (V1) | Cloud-based Grill-me incubation, doc generation, specialist reasoning via Supabase Edge Functions. |
| **Secondary LLM** | Google Gemini 1.5 Pro / Flash | Active (V1) | Multimodal asset analysis and fallback provider. |
| **Local SLM Engine** | PyTorch / ExecuTorch | Planned (V2) | On-device SLM support for offline AI incubation sessions. |
