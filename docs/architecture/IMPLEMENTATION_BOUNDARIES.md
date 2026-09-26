# ThinkNest Implementation Boundaries

**Status:** Normative for P0 implementation

## Stack

- Flutter / Dart
- Riverpod for presentation/application state
- Drift for local persistence (P0.2)
- Supabase for cloud services and synchronization (P1)
- Provider Abstraction Layer for AI integrations

## Layering

```
Presentation
    ↓
Application
    ↓
Domain
    ↓
Infrastructure
```

Business rules belong in Domain/Application layers. Infrastructure adapters must not become the source of domain behavior.

## P0 implementation rule

The first implementation slice must remain intentionally small:

`Capture → Project → Project DNA → Conversation → Documents → Readiness → Export`

Authentication, cloud synchronization, plugins, premium, analytics, and secondary integrations are not prerequisites for the local core.

## Legacy architecture cleanup

The implementation target is Flutter/Dart. References to React Native, WatermelonDB, Jest, Detox, and RxJS in older specifications are considered legacy and must not be used for new code. The affected documents will be corrected as their implementation slice is completed.

## Dart/Flutter and CI standards

The implementation must follow [`DART_FLUTTER_CI_STANDARDS.md`](DART_FLUTTER_CI_STANDARDS.md). This includes canonical `dart format`, deterministic Flutter/Dart tooling, valid Dart typing, canonical imports, Drift code generation, automated tests, and the rule that a P0 slice cannot advance while CI is red.

## Verification

Every implementation slice must provide:

1. source code;
2. automated tests for the changed behavior;
3. documentation aligned with the code;
4. a reproducible verification command;
5. no violation of the Product Constitution or ADRs.
