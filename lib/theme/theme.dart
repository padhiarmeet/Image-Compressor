import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: const Color(0xFFF4F1FF),
    surface: const Color(0xFFFFFFFF),
    primary: const Color(0xFF8B5FBF),
    secondary: const Color(0xFFE879F9),
    onBackground: const Color(0xFF2D1B69),
    onSurface: const Color(0xFFA5A3C7),
    outline: const Color(0xFF3B4070)

  )
);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: const Color(0xFF0A0B1E),
    surface: const Color(0xFF1A1B3A),
    primary: const Color(0xFF8B5FBF),
    secondary: const Color(0xFFE879F9),
    onBackground:const  Color(0xFFE8E6FF),
    onSurface:const Color(0xFF6B6394),
    outline: const Color(0xFFE1DCFF),
  )
);
