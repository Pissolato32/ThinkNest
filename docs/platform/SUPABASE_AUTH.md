# Supabase Auth — P1.1

ThinkNest keeps local persistence as the UI source of truth. Supabase Auth is an optional platform capability used to establish identity and later authorize synchronization.

## Configuration

Provide the Supabase project URL and publishable key at build/run time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Never place a service-role or secret key in the Flutter application.

If these values are absent, ThinkNest continues to start in offline/local mode.

## Current adapter

The provider-neutral domain contract is:

- `AuthRepository`
- `AuthSession`

The infrastructure adapter is:

- `SupabaseAuthRepository`

It currently supports:

- current session;
- session change stream;
- email/password sign-in;
- sign-out.

The UI does not read Supabase directly.

## Integration boundary

A real Supabase project is intentionally not hard-coded into the repository. Remote integration remains the next validation step once a project is connected.

The next P1 slice is synchronization. It must preserve the rule:

`UI → Drift → Sync Engine → Supabase`

Cloud data must never replace Drift as the runtime source of truth.
