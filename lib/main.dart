import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/data/viril_store.dart';
import 'features/profile/data/profile_store.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Auth is initialized before the UI so saved sessions can be restored.
  try {
    await SupabaseService.initialize();
  } catch (error, stackTrace) {
    debugPrint('Supabase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  // Local storage remains available even if the network service is unavailable.
  try {
    await VirilStore.instance.initialize();
    await ProfileStore.instance.initialize();
  } catch (error, stackTrace) {
    debugPrint('Viril startup storage initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const VirilApp());
}
