# ThinkNest Test Strategy Specification

**Version:** 1.0  
**Status:** Approved  
**Quality Assurance:** Test Architecture

---

## 1. Testing Pyramid & Automation

```
              ┌───────────────────────────┐
              │    E2E Tests (Detox)      │  (Critical flows: Capture, Grill-me, Export)
              └─────────────┬─────────────┘
                            │
              ┌─────────────┴─────────────┐
              │ Component / Screen Tests  │  (React Native Testing Library)
              └─────────────┬─────────────┘
                            │
              ┌─────────────┴─────────────┐
              │   Unit & Domain Tests     │  (Jest: DNA Merger, PAL Adapters, State Machines)
              └───────────────────────────┘
```

---

## 2. Test Execution Guidelines

- **Unit Tests:** High coverage (>85%) on domain entities, Project DNA extraction, and AI provider fallback logic.
- **E2E Automation:** Detox tests running on iOS Simulators and Android Emulators verifying instant capture and document generation flows.
