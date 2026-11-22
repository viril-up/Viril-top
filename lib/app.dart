import 'package:flutter/material.dart';
import 'core/theme/viril_theme.dart';
import 'core/widgets/particle_backdrop.dart';
import 'core/widgets/viril_splash_screen.dart';
import 'core/services/viril_audio_service.dart';

class VirilApp extends StatefulWidget {
  const VirilApp({super.key});

  @override
  State<VirilApp> createState() => _VirilAppState();
}

class _VirilAppState extends State<VirilApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    VirilAudioService.instance.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    VirilAudioService.instance.handleLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viril',
      debugShowCheckedModeBanner: false,
      theme: VirilTheme.dark,
      builder: (context, child) => ParticleBackdrop(
        child: child ?? const SizedBox.shrink(),
      ),
      home: const VirilSplashScreen(),
    );
  }
}
