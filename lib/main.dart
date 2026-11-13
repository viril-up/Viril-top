import 'package:flutter/material.dart';
import 'app.dart';
import 'core/data/viril_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VirilStore.instance.initialize();
  runApp(const VirilApp());
}
