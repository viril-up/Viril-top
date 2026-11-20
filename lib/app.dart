import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/viril_localization.dart';
import 'core/theme/viril_theme.dart';
import 'core/widgets/particle_backdrop.dart';
import 'core/widgets/viril_splash_screen.dart';

class VirilApp extends StatelessWidget {
  const VirilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: VirilLanguageController.instance,
      builder: (context, _) => MaterialApp(
        title: 'Viril',
        debugShowCheckedModeBanner: false,
        theme: VirilTheme.dark,
        locale: VirilLanguageController.instance.locale,
        supportedLocales: virilLanguageNames.values.map((code) => Locale(code)),
        localizationsDelegates: const [
          VirilStrings.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => ParticleBackdrop(
          child: child ?? const SizedBox.shrink(),
        ),
        home: const VirilSplashScreen(),
      ),
    );
  }
}
