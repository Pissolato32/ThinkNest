import 'auth_session.dart';

abstract interface class AuthRepository {
  AuthSession? get currentSession;

  Stream<AuthSession?> watchSession();

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
