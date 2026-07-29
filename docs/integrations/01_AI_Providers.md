# ThinkNest AI Provider & Speech Integrations

**Version:** 1.1  
**Status:** Approved  
**Module:** Integrations / AI & Speech Adapters

---

## 1. Supported AI & Speech Services

| Component | Target Engine / Provider | V1 Scope | Role & Strategy |
|---|---|---|---|
| **Speech-to-Text (Primary)** | Local Device API (`speech_to_text`) | Active (V1) | Primary offline-capable transcription engine using Android/iOS native STT. |
| **Speech Refinement** | Cloud Whisper API (OpenAI / Groq) | Active (V1) | Automatically refines local transcription when online connection is available. |
| **Primary LLM** | Anthropic Claude 3.5 Sonnet / OpenAI GPT-4o | Active (V1) | Cloud-based Grill-me incubation, doc generation, specialist reasoning via Supabase Edge Functions. |
| **Secondary LLM** | Google Gemini 1.5 Pro / Flash | Active (V1) | Multimodal asset analysis and fallback provider. |
| **Local SLM Engine** | PyTorch / ExecuTorch | Planned (V2) | On-device SLM support for offline AI incubation sessions. |
