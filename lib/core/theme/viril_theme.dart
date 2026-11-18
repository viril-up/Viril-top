import 'package:flutter/material.dart';
import 'viril_colors.dart';

class VirilPageTransitionsBuilder extends PageTransitionsBuilder {
  const VirilPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Opaque backing prevents transparent detail pages from showing the
    // previous tab/page underneath while the route is being built.
    return ColoredBox(
      color: VirilColors.black,
      child: child,
    );
  }
}

abstract final class VirilTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: VirilColors.gold,
      secondary: VirilColors.chartBlue,
      surface: VirilColors.stone,
      error: VirilColors.lava,
      onSurface: VirilColors.text,
    ),
    fontFamily: 'Roboto',
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: VirilPageTransitionsBuilder(),
        TargetPlatform.iOS: VirilPageTransitionsBuilder(),
        TargetPlatform.linux: VirilPageTransitionsBuilder(),
        TargetPlatform.macOS: VirilPageTransitionsBuilder(),
        TargetPlatform.windows: VirilPageTransitionsBuilder(),
      },
    ),
    splashFactory: InkRipple.splashFactory,
    splashColor: VirilColors.ice.withValues(alpha: .055),
    highlightColor: VirilColors.ice.withValues(alpha: .025),
    hoverColor: VirilColors.ice.withValues(alpha: .025),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: VirilColors.text),
      bodyMedium: TextStyle(color: VirilColors.text),
      bodySmall: TextStyle(color: VirilColors.muted),
      titleLarge: TextStyle(color: VirilColors.ice, fontWeight: FontWeight.w800, letterSpacing: .15),
      titleMedium: TextStyle(color: VirilColors.text, fontWeight: FontWeight.w700),
      titleSmall: TextStyle(color: VirilColors.text, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(color: VirilColors.ice, fontWeight: FontWeight.w900, letterSpacing: .25),
      labelLarge: TextStyle(color: VirilColors.text, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: VirilColors.text,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: VirilColors.black,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: VirilColors.line, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: VirilColors.black,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: VirilColors.line, width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: VirilColors.black,
      selectedColor: VirilColors.navyLight,
      side: BorderSide(color: VirilColors.line),
      labelStyle: const TextStyle(color: VirilColors.text),
      secondaryLabelStyle: const TextStyle(color: VirilColors.ice),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: VirilColors.black,
      indicatorColor: VirilColors.navyLight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
        color: states.contains(WidgetState.selected) ? VirilColors.ice : VirilColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
        color: states.contains(WidgetState.selected) ? VirilColors.gold : VirilColors.muted,
      )),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? VirilColors.text : VirilColors.muted),
      trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? VirilColors.navyLight : VirilColors.line),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: VirilColors.chartBlue,
      linearTrackColor: VirilColors.line,
    ),
    dividerTheme: const DividerThemeData(color: VirilColors.line, thickness: 1),
    iconTheme: const IconThemeData(color: VirilColors.muted),
  );
}
