# ThinkNest AI Engine Core Specification

**Version:** 2.0  
**Status:** Approved  
**Normative ADRs:** ADR-0016, ADR-0021, ADR-0023, ADR-0024

---

## 1. AI Confidence Model (ADR-0021)

Every AI inference output is evaluated against confidence thresholds before mutating state:

- **Confidence > 95%:** Automatically update Project DNA and emit `DNAUpdatedEvent`.
- **Confidence 80% – 95%:** Present modification as an interactive UI **Suggestion Card** for 1-tap user approval.
- **Confidence < 80%:** Formulate a targeted, single question to clarify intent before making changes.

---

## 2. Progressive Context Compression Pipeline (ADR-0023)

To maintain long-term conversation history without token inflation, the engine compresses context:

```
Raw Conversation ──► Summaries ──► Fact Extraction ──► Decision Locking ──► Project DNA ──► Dynamic Compression ──► Provider Payload (< 1,500 Tokens)
```

---

## 3. AI Cost Governance & Model Routing (ADR-0024)

Task-based model routing minimizes API expenses while maximizing output quality:

| Task Type | Complexity | Assigned Model Class | Example Providers |
|---|---|---|---|
| **Quick Capture & STT Refinement** | Low | Fast & Lightweight | Whisper / Claude 3.5 Haiku / GPT-4o-mini |
| **Summarization & Fact Extraction** | Medium | High Throughput | Gemini 1.5 Flash |
| **Architecture & PRD Generation** | High | Deep Reasoning | Claude 3.5 Sonnet / GPT-4o / o3-mini |
| **Export Profile Compilation** | Low / Structured | Deterministic Formatters | Client-Side Dart Builder |
