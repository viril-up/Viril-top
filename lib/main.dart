import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/localization/viril_localization.dart';
import 'core/data/viril_store.dart';
import 'features/profile/data/profile_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage initialization must never prevent the application from rendering.
  try {
    await VirilStore.instance.initialize();
    await ProfileStore.instance.initialize();
  } catch (error, stackTrace) {
    debugPrint('Viril startup storage initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  await VirilLanguageController.instance.initialize();
  runApp(const VirilApp());
}
