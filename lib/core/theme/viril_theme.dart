import 'package:flutter/material.dart';
import 'viril_colors.dart';

abstract final class VirilTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: VirilColors.voidBlack,
    colorScheme: const ColorScheme.dark(
      primary: VirilColors.ice,
      secondary: VirilColors.gold,
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
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xEE10131E),
      indicatorColor: VirilColors.ice.withValues(alpha: .13),
      labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
        color: states.contains(WidgetState.selected) ? VirilColors.ice : VirilColors.muted,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      )),
    ),
  );
}
