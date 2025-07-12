// import 'package:flutter/material.dart';
//
// ThemeData lightMode = ThemeData(
//   brightness: Brightness.light,
//   colorScheme: ColorScheme.light(
//     background: const Color(0xFFF4F1FF),
//     surface: const Color(0xFFFFFFFF),
//     primary: const Color(0xFF8B5FBF),
//     secondary: const Color(0xFFE879F9),
//     onBackground: const Color(0xFF2D1B69),
//     onSurface: const Color(0xFFA5A3C7),
//     outline: const Color(0xFF3B4070)
//
//
//   )
// );
//
// ThemeData darkMode = ThemeData(
//     brightness: Brightness.dark,
//   colorScheme: ColorScheme.dark(
//     background: const Color(0xFF0A0B1E),
//     surface: const Color(0xFF1A1B3A),
//     primary: const Color(0xFF8B5FBF),
//     secondary: const Color(0xFFE879F9),
//     onBackground:const  Color(0xFFE8E6FF),
//     onSurface:const Color(0xFF6B6394),
//     outline: const Color(0xFFE1DCFF),
//   )
// );

import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    // Main background - Clean neutral with warmth
    // background: Color(0xFFFBFBFB),
        background: Color(0xfff2f5f8),
    // Surface colors - Pure white and light variations
    surface: Color(0xFFFFFFFF),
    //   surface: Color(0xffe3f6fb),
    // Primary brand color - Professional teal - 488FB1
    // primary: Color(0xff438A70),
      primary: Color(0xFF0079bf),
    // Secondary accent - Complementary orange
    // secondary: Color(0xFFF97316),
      secondary: Color(0xFF5ba4cf),
    // Text colors
    onBackground: Color(0xFF0F172A),
    onSurface: Color(0xFF475569),

    // Border and outline colors
    outline: Color(0xFFE2E8F0),

    // Additional colors
    tertiary: Color(0xFFF8FAFC),
    onTertiary: Color(0xFF334155),

    // Error colors
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),

    // Success/positive colors
    inversePrimary: Color(0xFF059669),

    // Additional semantic colors
    surfaceVariant: Color(0xFFF1F5F9),
    onSurfaceVariant: Color(0xFF64748B),
    primaryContainer: Color(0xFFCCFDF7),
    onPrimaryContainer: Color(0xFF134E4A),
  ),

  // Card theme
  cardTheme: const CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  // Elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
    ),
  ),
);


ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    // Main background - Deep professional dark (0F172A)
    // background: Color(0xFF0F0D15),
      background: Color(0xFF121212),

    // Surface colors - Layered dark surfaces (1E293B)
    // surface: Color(0xFF1D1A26),
      surface: Color(0xFF1E1E1E),

    // Primary brand color - Bright teal for dark mode (14B8A6)  60A5FA {{3B82F6}}
    // primary: Color(0xff1e95d4),
        primary: Color(0xFF0079bf),

    // Secondary accent - Vibrant orange
    // secondary: Color(0xFFFB923C),
    secondary: Color(0xFF71AFE5),

    // Text colors
    onBackground: Color(0xFFF8FAFC),
    onSurface: Color(0xFFCBD5E1),

    // Border and outline colors
    outline: Color(0xFF475569),

    // Additional colors
    tertiary: Color(0xFF334155),
    onTertiary: Color(0xFF94A3B8),

    // Error colors
    error: Color(0xFFF87171),
    onError: Color(0xFF1F2937),

    // Success/positive colors
    inversePrimary: Color(0xFF10B981),

    // Additional semantic colors
    surfaceVariant: Color(0xFF475569),
    onSurfaceVariant: Color(0xFF94A3B8),
    primaryContainer: Color(0xFF134E4A),
    onPrimaryContainer: Color(0xFFCCFDF7),
  ),

  // Card theme
  cardTheme: const CardThemeData(
    elevation: 0,
    color: Color(0xFF1E293B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  // Elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),

  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF475569)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF475569)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
    ),
  ),
);

// Professional color constants
class AppColors {
  // Light mode colors
  static const lightPrimary = Color(0xFF0D9488);
  static const lightSecondary = Color(0xFFF97316);
  static const lightBackground = Color(0xFFFBFBFB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSuccess = Color(0xFF059669);
  static const lightWarning = Color(0xFFFBBF24);
  static const lightError = Color(0xFFDC2626);
  static const lightInfo = Color(0xFF0EA5E9);

  // Dark mode colors
  static const darkPrimary = Color(0xFF14B8A6);
  static const darkSecondary = Color(0xFFFB923C);
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSuccess = Color(0xFF10B981);
  static const darkWarning = Color(0xFFFBBF24);
  static const darkError = Color(0xFFF87171);
  static const darkInfo = Color(0xFF38BDF8);

  // Neutral colors
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral500 = Color(0xFF64748B);
  static const neutral600 = Color(0xFF475569);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);

  // Status colors
  static const statusSuccess = Color(0xFF10B981);
  static const statusWarning = Color(0xFFF59E0B);
  static const statusError = Color(0xFFEF4444);
  static const statusInfo = Color(0xFF3B82F6);
}