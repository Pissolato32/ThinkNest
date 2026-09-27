import 'package:flutter_test/flutter_test.dart';

import 'package:thinknest/core/domain/auth/auth_session.dart';
import 'package:thinknest/core/infrastructure/supabase/supabase_config.dart';

void main() {
  test('auth session exposes provider-neutral identity and expiry', () {
    final session = AuthSession(
      userId: 'user-1',
      accessToken: 'token',
      expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
    );

    expect(session.userId, 'user-1');
    expect(session.accessToken, 'token');
    expect(session.isExpired, isFalse);
  });

  test('Supabase configuration is invalid when credentials are absent', () {
    const config = SupabaseConfig(url: '', publishableKey: '');

    expect(config.isValid, isFalse);
  });
}
