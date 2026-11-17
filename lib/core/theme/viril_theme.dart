import 'package:flutter/material.dart';
import 'viril_colors.dart';

abstract final class VirilTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: VirilColors.voidBlack,
    colorScheme: const ColorScheme.dark(
      primary: VirilColors.gold,
      secondary: VirilColors.navyLight,
      surface: VirilColors.black,
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
      color: VirilColors.black,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: VirilColors.line, width: 1),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: VirilColors.stone,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: VirilColors.stoneEdge)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: VirilColors.stone,
      selectedColor: VirilColors.navyLight.withValues(alpha: .48),
      side: const BorderSide(color: VirilColors.line),
      labelStyle: const TextStyle(color: VirilColors.text),
      secondaryLabelStyle: const TextStyle(color: VirilColors.ice),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xF20A0D13),
      indicatorColor: VirilColors.navyLight.withValues(alpha: .52),
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
        color: states.contains(WidgetState.selected) ? VirilColors.ice : VirilColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
        color: states.contains(WidgetState.selected) ? VirilColors.gold : VirilColors.muted,
      )),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? VirilColors.ice : VirilColors.muted),
      trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected) ? VirilColors.navyLight : VirilColors.line),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: VirilColors.gold,
      linearTrackColor: VirilColors.line,
    ),
    dividerTheme: const DividerThemeData(color: VirilColors.line, thickness: 1),
  );
}
