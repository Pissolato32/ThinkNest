import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/auth/auth_repository.dart';
import '../../domain/auth/auth_session.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  AuthSession? get currentSession => _mapSession(_client.auth.currentSession);

  @override
  Stream<AuthSession?> watchSession() {
    return _client.auth.onAuthStateChange.map(
      (state) => _mapSession(state.session),
    );
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final session = response.session;
    if (session == null) {
      throw StateError('Supabase authentication returned no session.');
    }
    return _mapSession(session)!;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  AuthSession? _mapSession(Session? session) {
    if (session == null) return null;
    final expiresAt = session.expiresAt;
    return AuthSession(
      userId: session.user.id,
      accessToken: session.accessToken,
      expiresAt: expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              expiresAt * 1000,
              isUtc: true,
            ),
    );
  }
}
