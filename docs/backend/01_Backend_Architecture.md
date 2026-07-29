# ThinkNest Backend Architecture Specification

**Version:** 1.1  
**Status:** Approved  
**Infrastructure:** Supabase (V1 Platform) + Provider-Agnostic Abstraction

---

## 1. Overview & Cloud Architecture

V1 utilizes **Supabase** as the primary backend ecosystem. The Flutter client interacts with backend services through abstracted Repository interfaces to ensure zero hard dependency lock-in.

```
┌────────────────────────────────────────────────────────┐
│               Flutter Client App (Android & Web)       │
└──────────────────────────┬─────────────────────────────┘
                           │ HTTPS / WebSockets / RLS
                           ▼
┌────────────────────────────────────────────────────────┐
│                   Supabase Platform (V1)               │
│  ┌──────────────────┐ ┌──────────────────────────────┐ │
│  │ Supabase Auth    │ │ PostgreSQL DB (RLS Enabled)  │ │
│  │ (Email/Google)   │ │                              │ │
│  └──────────────────┘ └──────────────────────────────┘ │
│  ┌──────────────────┐ ┌──────────────────────────────┐ │
│  │ Supabase Storage │ │ Supabase Edge Functions      │ │
│  │ (Audio/Media)    │ │ (Deno / TS - AI Proxy)       │ │
│  └──────────────────┘ └──────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

---

## 2. Component Specifications

1. **Supabase Auth:** Handles guest-to-registered user upgrade, OAuth (Google & Email magic link), and JWT session issuance.
2. **PostgreSQL Database:** Multi-tenant relational schema secured via Row-Level Security (RLS) policies.
3. **Supabase Storage:** Encrypted buckets for audio recordings, image attachments, and exported Implementation Packs.
4. **Edge Functions (Deno/TS):** Acts as the AI Proxy Gateway, hiding provider API keys, handling rate limits, and streaming LLM responses to Flutter clients.
5. **Provider-Agnostic Abstraction Layer:** Flutter app code accesses data strictly via interfaces (`IAuthRepository`, `IProjectRepository`, `IAIGateway`) allowing backend migration if required in future releases.
