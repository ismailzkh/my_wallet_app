import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const black = Color(0xFF000000);

    const bg = Color(0xFFF7F8FA);
    const bgSoft = Color(0xFFF1F3F5);
    const surface = Color(0xFFFFFFFF);
    const surfaceAlt = Color(0xFFF3F5F7);
    const surfaceRaised = Color(0xFFFFFFFF);

    const divider = Color(0xFFE4E7EC);
    const chip = Color(0xFFEEF2F6);

    const white = Color(0xFFFFFFFF);
    const textPrimary = Color(0xFF111827);
    const textSecondary = Color(0xFF667085);
    const textMuted = Color(0xFF98A2B3);
    const textFaint = Color(0xFFB6BDC8);

    const okxGreen = Color(0xFF00C853);
    const okxGreenPressed = Color(0xFF00B34A);
    const okxGreenBright = Color(0xFF33D975);

    const success = okxGreen;
    const danger = Color(0xFFE53935);
    const warning = Color(0xFFF59E0B);
    const info = Color(0xFF00B894);

    final colorScheme = const ColorScheme.light(
      primary: okxGreen,
      secondary: okxGreenBright,
      surface: surface,
      error: danger,
      onPrimary: black,
      onSecondary: white,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: const BorderSide(color: divider),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: okxGreenBright, width: 1.2),
        ),
        hintStyle: const TextStyle(color: textFaint),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: okxGreen,
          foregroundColor: black,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(okxGreenBright),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00C853), // or okxGreen if you prefer
        foregroundColor: black,
        elevation: 0,
        shape: StadiumBorder(), // pill shape like your chips
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: surfaceAlt,
        elevation: 0,
        height: 66,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      extensions: const [
        AppColors(
          black: black,
          bg: bg,
          bgSoft: bgSoft,
          surface: surface,
          surfaceAlt: surfaceAlt,
          surfaceRaised: surfaceRaised,
          divider: divider,
          chip: chip,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          textMuted: textMuted,
          textFaint: textFaint,
          green: okxGreen,
          greenPressed: okxGreenPressed,
          greenBright: okxGreenBright,
          success: success,
          danger: danger,
          warning: warning,
          info: info,
        ),
      ],
    );
  }

  static ThemeData dark() {
    const black = Color(0xFF000000);
    const bg = Color(0xFF000000);
    const bgSoft = Color(0xFF0B0B0B);
    const surface = Color(0xFF121212);
    const surfaceAlt = Color(0xFF1A1A1A);
    const surfaceRaised = Color(0xFF161616);

    const divider = Color(0xFF222222);
    const chip = Color(0xFF1C1C1C);

    const white = Color(0xFFFFFFFF);
    const textPrimary = Color(0xFFEDEDED);
    const textSecondary = Color(0xFF9E9E9E);
    const textMuted = Color(0xFF6B6B6B);
    const textFaint = Color(0xFF5A5A5A);

    const okxGreen = Color(0xFF00FF66);
    const okxGreenPressed = Color(0xFF00E65C);
    const okxGreenBright = Color(0xFF33FF85);

    const success = okxGreen;
    const danger = Color(0xFFFF4D4D);
    const warning = Color(0xFFFF9F1A);
    const info = Color(0xFF00B894);

    final colorScheme = const ColorScheme.dark(
      primary: okxGreen,
      secondary: okxGreenBright,
      surface: surface,
      error: danger,
      onPrimary: black,
      onSecondary: white,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: black,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: okxGreenBright, width: 1.2),
        ),
        hintStyle: const TextStyle(color: textFaint),
        labelStyle: const TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: okxGreen,
          foregroundColor: black,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(okxGreenBright),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00C853), // or okxGreen if you prefer
        foregroundColor: black,
        elevation: 0,
        shape: StadiumBorder(), // pill shape like your chips
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: surfaceAlt,
        elevation: 0,
        height: 66,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      extensions: const [
        AppColors(
          black: black,
          bg: bg,
          bgSoft: bgSoft,
          surface: surface,
          surfaceAlt: surfaceAlt,
          surfaceRaised: surfaceRaised,
          divider: divider,
          chip: chip,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          textMuted: textMuted,
          textFaint: textFaint,
          green: okxGreen,
          greenPressed: okxGreenPressed,
          greenBright: okxGreenBright,
          success: success,
          danger: danger,
          warning: warning,
          info: info,
        ),
      ],
    );
  }
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color black;
  final Color bg;
  final Color bgSoft;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceRaised;
  final Color divider;
  final Color chip;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textFaint;
  final Color green;
  final Color greenPressed;
  final Color greenBright;
  final Color success;
  final Color danger;
  final Color warning;
  final Color info;

  const AppColors({
    required this.black,
    required this.bg,
    required this.bgSoft,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceRaised,
    required this.divider,
    required this.chip,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textFaint,
    required this.green,
    required this.greenPressed,
    required this.greenBright,
    required this.success,
    required this.danger,
    required this.warning,
    required this.info,
  });

  @override
  AppColors copyWith({
    Color? black,
    Color? bg,
    Color? bgSoft,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceRaised,
    Color? divider,
    Color? chip,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textFaint,
    Color? green,
    Color? greenPressed,
    Color? greenBright,
    Color? success,
    Color? danger,
    Color? warning,
    Color? info,
  }) {
    return AppColors(
      black: black ?? this.black,
      bg: bg ?? this.bg,
      bgSoft: bgSoft ?? this.bgSoft,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      divider: divider ?? this.divider,
      chip: chip ?? this.chip,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      green: green ?? this.green,
      greenPressed: greenPressed ?? this.greenPressed,
      greenBright: greenBright ?? this.greenBright,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return this;
  }
}
