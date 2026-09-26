# ThinkNest

![Flutter](https://img.shields.io/badge/Flutter-implementation%20in%20progress-blue.svg)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20Web%20(V1)-lightgrey.svg)
![Architecture](https://img.shields.io/badge/Architecture-Offline--First%20%26%20DDD-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

ThinkNest is an AI-powered project incubator that transforms raw ideas into implementation-ready specifications.

## Current status

The repository is transitioning from its approved architecture/documentation baseline to the functional Flutter implementation.

The implementation is being delivered incrementally through vertical slices. The first target is:

`Capture → Project → Project DNA → Conversation → Documents → Readiness → Implementation Pack`

See [docs/IMPLEMENTATION_PLAN.md](docs/IMPLEMENTATION_PLAN.md) and issue [#5](https://github.com/Pissolato32/ThinkNest/issues/5).

## Local development

The P0.1 source shell is now present.

```bash
flutter create . --platforms=android,web
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run
```

`flutter create` is currently needed because the repository intentionally commits the platform-independent application source first; generated Android/Web platform files will be added when the first runnable application slice is stabilized.

## Documentation

See [docs/README.md](docs/README.md) for the canonical documentation hub.

## CI e padrões de código

As regras obrigatórias de Dart/Flutter, formatação, análise, Drift, testes e diagnóstico de falhas estão em [`docs/architecture/DART_FLUTTER_CI_STANDARDS.md`](docs/architecture/DART_FLUTTER_CI_STANDARDS.md).
