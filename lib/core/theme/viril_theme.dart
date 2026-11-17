import 'package:flutter/material.dart';
import 'viril_colors.dart';

abstract final class VirilTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: VirilColors.voidBlack,
    colorScheme: const ColorScheme.dark(
      primary: VirilColors.gold,
      secondary: VirilColors.ice,
      surface: VirilColors.stone,
      error: VirilColors.lava,
    ),
    fontFamily: 'Roboto',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: VirilColors.text,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: VirilColors.stone,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: VirilColors.line),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: VirilColors.stone,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: VirilColors.stoneLight,
      selectedColor: VirilColors.gold.withValues(alpha: .18),
      side: const BorderSide(color: VirilColors.line),
      labelStyle: const TextStyle(color: VirilColors.text),
      secondaryLabelStyle: const TextStyle(color: VirilColors.gold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xEE171619),
      indicatorColor: VirilColors.gold.withValues(alpha: .16),
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
        color: states.contains(WidgetState.selected) ? VirilColors.gold : VirilColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
        color: states.contains(WidgetState.selected) ? VirilColors.gold : VirilColors.muted,
      )),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? VirilColors.gold : VirilColors.muted),
      trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? VirilColors.gold.withValues(alpha: .35) : VirilColors.line),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: VirilColors.gold,
      linearTrackColor: VirilColors.line,
    ),
  );
}
