# ThinkNest AI Provider Abstraction Layer (ADR-0016 & ADR-0024)

**Version:** 2.0  
**Status:** Approved  
**Normative ADRs:** ADR-0016 (AI Provider Abstraction) & ADR-0024 (AI Cost Governance)

---

## 1. Provider Abstraction Layer (PAL) Architecture

In accordance with **ADR-0016**, ThinkNest is completely independent of any specific AI provider. LLMs are treated as interchangeable execution engines.

```
                            ┌───────────────────────────────┐
                            │    ThinkNest Core AI Engine   │
                            └───────────────┬───────────────┘
                                            │
                                            ▼
                            ┌───────────────────────────────┐
                            │  Provider Abstraction Layer   │
                            │   (PAL Gateway - ADR-0016)    │
                            └───────────────┬───────────────┘
                                            │
         ┌──────────────────┬───────────────┼───────────────┬──────────────────┐
         ▼                  ▼               ▼               ▼                  ▼
┌─────────────────┐ ┌───────────────┐ ┌───────────┐ ┌───────────────┐ ┌─────────────────┐
│ OpenAI Adapter  │ │ Anthropic Ad. │ │ Gemini Ad.│ │ OpenRouter Ad.│ │ DeepSeek / Local│
│ (GPT-4o/o3-mini)│ │ (Claude 3.5)  │ │ (1.5 Pro) │ │ (Aggregator)  │ │ (Llama / SLM)   │
└─────────────────┘ └───────────────┘ └───────────┘ └───────────────┘ └─────────────────┘
```

---

## 2. Responsibilities of PAL

1. **Request/Response Normalization:** Convert provider-agnostic Project DNA payload into provider parameters and map raw responses to standard outputs.
2. **Dynamic Policy Routing (ADR-0024):** Model selection based on task complexity, latency, estimated cost, and user subscription tier.
3. **Resilience & Transparent Failover:** Automatic retries on HTTP 429 / 5xx timeouts using compatible fallback providers without disrupting the user.
4. **Cost & Token Accounting:** Meter input/output tokens and calculate per-turn API expense logs.
