# ThinkNest State Machines (ADR-0019 & ADR-0020)

**Version:** 2.0  
**Status:** Approved  
**Normative ADRs:** ADR-0019 (Snapshot Immutability) & ADR-0020 (Document Lifecycle)

---

## 1. Document Lifecycle State Machine (ADR-0020)

Every document generated or edited in ThinkNest follows a deterministic lifecycle:

```
┌─────────┐         ┌───────────┐         ┌───────────────┐         ┌──────────┐         ┌──────────┐
│  Draft  ├────────►│ Generated ├────────►│ User Reviewed ├────────►│ Approved ├────────►│ Archived │
└─────────┘         └───────────┘         └───────────────┘         └──────────┘         └──────────┘
```

### Lifecycle Transition Rules
1. **`Draft`:** AI initial outline or partial user input.
2. **`Generated`:** Synthesized by AI Orchestrator based on Project DNA (requires user review).
3. **`User Reviewed`:** User has viewed or lightly edited the generated artifact.
4. **`Approved`:** User explicitly locks the document as an authoritative project specification. Accepted content becomes protected under Human Authority (ADR-0028).
5. **`Archived`:** Superseded document versions stored for historical timeline tracking.

---

## 2. Snapshot Immutability Engine (ADR-0019)

- **Immutable Milestone Snapshots:** Every major mutation (Document Approval, DNA Lock, Maturity Level advancement) creates a read-only, hash-verified Snapshot.
- **Snapshot Timeline:** Snapshots cannot be altered once written. Users can inspect historical diffs or restore a project state to a prior snapshot.
