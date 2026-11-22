import 'package:material_ui/material_ui.dart';

/// Couleurs de la proposition 2 « Studio ».
class CaviColors {
  CaviColors._();
  static const bg = Color(0xFF0C1020);
  static const card = Color(0xFF161C30);
  static const card2 = Color(0xFF252D48);
  static const nav = Color(0xF51E2640);
  static const blue = Color(0xFF2F6FE0);
  static const blueLight = Color(0xFF9CBCFF);
  static const red = Color(0xFFE8262B);
  static const redLight = Color(0xFFFF6B6F);
  static const violet = Color(0xFF5B55C9);
  static const text = Color(0xFFF2F4FA);
  static const sub = Color(0xFFA3ABC4);
}

class CaviRadius {
  CaviRadius._();
  static const card = 22.0;
  static const tile = 14.0;
}

ThemeData buildCaviTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: CaviColors.blue,
      onPrimary: Colors.white,
      secondary: CaviColors.red,
      onSecondary: Colors.white,
      surface: CaviColors.card,
      onSurface: CaviColors.text,
      error: CaviColors.redLight,
    ),
    scaffoldBackgroundColor: CaviColors.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: CaviColors.text,
      displayColor: CaviColors.text,
      fontFamily: 'Inter',
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: CaviColors.bg,
      foregroundColor: CaviColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: CaviColors.text,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: CaviColors.card2,
      contentTextStyle: TextStyle(fontFamily: 'Inter', color: CaviColors.text),
      behavior: SnackBarBehavior.floating,
    ),
    dividerColor: CaviColors.card2,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : CaviColors.sub,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? CaviColors.blue : CaviColors.card2,
      ),
    ),
  );
}
