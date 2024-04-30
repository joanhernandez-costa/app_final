import 'package:app_final/models/AppTheme.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:flutter/material.dart';

class ThemeService {
  static final Map<String, AppTheme> availableThemes = {
    'default': AppTheme(
      primary: const Color.fromRGBO(255, 166, 43, 1),
      primaryVariant: ColorService.changeLightness(
          const Color.fromRGBO(255, 166, 43, 1), 0.5),
      secondary: const Color.fromRGBO(22, 105, 122, 1),
      secondaryVariant: ColorService.getComplementaryColor(
          ColorService.changeLightness(
              const Color.fromRGBO(255, 166, 43, 1), 0.5)),
      background: const Color.fromRGBO(130, 192, 204, 1),
      surface: const Color.fromRGBO(72, 159, 181, 1),
      error: const Color(0xFFB00020),
      textOnPrimary: const Color.fromRGBO(237, 231, 227, 1),
      textOnSecondary: const Color.fromARGB(255, 0, 0, 0),
      textOnBackground: const Color.fromARGB(255, 54, 54, 54),
      textOnSurface: const Color(0xFF000000),
      textOnError: const Color(0xFFFFFFFF),
    ),
  };

  static AppTheme currentTheme = availableThemes['default']!;

  static void switchTheme(String themeKey) {
    if (availableThemes.containsKey(themeKey)) {
      currentTheme = availableThemes[themeKey]!;
    }
  }
}
