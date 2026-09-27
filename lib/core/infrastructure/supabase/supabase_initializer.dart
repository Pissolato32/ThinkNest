import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class SupabaseInitializer {
  const SupabaseInitializer();

  Future<bool> initialize(SupabaseConfig config) async {
    if (!config.isValid) return false;

    await Supabase.initialize(
      url: config.url,
      publishableKey: config.publishableKey,
    );
    return true;
  }
}
