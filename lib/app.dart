import 'package:flutter/material.dart';
import 'core/theme/viril_theme.dart';
import 'core/widgets/viril_shell.dart';
import 'core/widgets/particle_backdrop.dart';
import 'core/widgets/viril_splash_screen.dart';

class VirilApp extends StatelessWidget {
  const VirilApp({super.key});

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
