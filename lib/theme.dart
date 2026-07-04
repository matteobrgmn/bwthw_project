import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//main app styling component colors
abstract class AppColors {
  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF151515);
  static const surfaceHigh = Color(0xFF1E1E1E);
  static const outline = Color(0xFF2A2A2A);
  static const accent = Color(0xFFC8FF00);
  static const onAccent = Color(0xFF0A0A0A);
  static const text = Color(0xFFF2F2F2);
  static const muted = Color(0xFF9A9A9A);
  static const danger = Color(0xFFFF5C5C);

  //macro palette colors
  static const protein = Color(0xFFC8FF00);
  static const carbs = Color(0xFF4DD9E8);
  static const fat = Color(0xFFFFB020);
}

//defining how numbers should be displayed
TextStyle displayNumber({double size = 44, Color color = AppColors.text}) =>
    GoogleFonts.barlowCondensed(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.0,
    );

//the general theme blueprint for the app, hardcoded once for all
ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    surface: AppColors.bg,
    surfaceContainerHighest: AppColors.surfaceHigh,
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    secondary: AppColors.carbs,
    onSecondary: AppColors.onAccent,
    error: AppColors.danger,
    onSurface: AppColors.text,
    outline: AppColors.outline,
  );

  final body = GoogleFonts.manropeTextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: AppColors.text, displayColor: AppColors.text);
  final textTheme = body.copyWith(
    displayLarge: displayNumber(size: 56),
    displayMedium: displayNumber(size: 44),
    displaySmall: displayNumber(size: 34),
    headlineMedium: GoogleFonts.barlowCondensed(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.text,
      letterSpacing: 0.5,
    ),
    titleLarge: GoogleFonts.manrope(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    ),
    titleSmall: GoogleFonts.manrope(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
      letterSpacing: 1.2,
    ),
  );

  //overall theme of the app, defined for each component used
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.headlineMedium,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.outline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.muted),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: AppColors.surface,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: textTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.outline),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accent,
      labelStyle: GoogleFonts.manrope(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      secondaryLabelStyle: GoogleFonts.manrope(
        color: AppColors.onAccent,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      side: const BorderSide(color: AppColors.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.accent : null,
      ),
      checkColor: const WidgetStatePropertyAll(AppColors.onAccent),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.surfaceHigh,
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.surfaceHigh),
      ),
    ),
    canvasColor: AppColors.surfaceHigh, // DropdownButton menu background
  );
}
