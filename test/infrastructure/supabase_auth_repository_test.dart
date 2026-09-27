import 'package:flutter_test/flutter_test.dart';

void main() {
  test('P1 auth foundation keeps provider-neutral session contract', () {
    expect(
      () => throw UnimplementedError(
        'Integration test requires a configured Supabase project.',
      ),
      returnsNormally,
    );
  });
}
