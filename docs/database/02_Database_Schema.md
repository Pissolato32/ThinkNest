# ThinkNest Database Schema (Local Drift & Supabase PostgreSQL)

**Version:** 1.3  
**Status:** Approved  
**Engines:** Drift (Dart/SQLite) Local & Supabase PostgreSQL Remote

## P0 local schema

The first implementation slice contains three local-first tables:

- `projects`: project identity and lifecycle state.
- `project_dna`: authoritative Project DNA JSON and version.
- `project_snapshots`: immutable project timeline entries.

SQLite IDs are generated in Dart. JSON is stored as TEXT. Timestamps use Drift DateTime columns and are persisted according to Drift's SQLite mapping.

### Drift implementation

The normative P0 source is:

`lib/core/infrastructure/database/thinknest_database.dart`

The generated `thinknest_database.g.dart` file is produced by:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Remote schema

The Supabase PostgreSQL schema remains the source for P1 cloud synchronization. Its existing `projects`, `project_dna`, `messages`, and `documents` contracts remain unchanged.

## Migration rule

Schema changes require:
1. incrementing `schemaVersion`;
2. adding a Drift migration;
3. adding migration tests;
4. updating the remote schema when the changed entity participates in synchronization.
