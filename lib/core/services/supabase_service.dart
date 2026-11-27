import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static const String url = 'https://pjewrbblgnchzlznlpld.supabase.co';
  static const String publishableKey = 'sb_publishable_b1FijMpj7rSLWdPDnyA-XA_tDNBnYFh';

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: url,
      anonKey: publishableKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _initialized = true;
  }
}
