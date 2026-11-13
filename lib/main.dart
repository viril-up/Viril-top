import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/data/viril_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Storage initialization must never prevent the application from rendering.
  try {
    await VirilStore.instance.initialize();
  } catch (error, stackTrace) {
    debugPrint('Viril startup storage initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const VirilApp());
}
