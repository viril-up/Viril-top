import 'package:flutter/material.dart';
import 'viril_colors.dart';

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
        side: BorderSide(color: VirilColors.goldSoft.withValues(alpha: .62), width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: VirilColors.black,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: VirilColors.goldSoft.withValues(alpha: .72), width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: VirilColors.black,
      selectedColor: VirilColors.navyLight,
      side: BorderSide(color: VirilColors.goldSoft.withValues(alpha: .55)),
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
