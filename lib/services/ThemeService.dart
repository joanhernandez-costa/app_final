import 'package:app_final/models/AppTheme.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:flutter/material.dart';

class ThemeService with ChangeNotifier {
  static const Color basePrimary = Color.fromRGBO(255, 166, 43, 1);
  static Color basePrimaryVariant =
      ColorService.changeLightness(basePrimary, 0.5);
  static const Color baseSecondary = Color.fromRGBO(22, 105, 122, 1);
  static Color baseSecondaryVariant =
      ColorService.getComplementaryColor(basePrimaryVariant);
  static const Color baseBackground = Color.fromRGBO(130, 192, 204, 1);
  static const Color baseSurface = Color.fromRGBO(72, 159, 181, 1);
  static const Color baseError = Color(0xFFB00020);
  static const Color baseTextOnPrimary = Color.fromRGBO(237, 231, 227, 1);
  static const Color baseTextOnSecondary = Color.fromARGB(255, 0, 0, 0);
  static const Color baseTextOnBackground = Color.fromARGB(255, 54, 54, 54);
  static const Color baseTextOnSurface = Color(0xFF000000);
  static const Color baseTextOnError = Color(0xFFFFFFFF);

  static final Map<String, AppTheme> availableThemes = {
    'default': AppTheme(
      primary: basePrimary,
      primaryVariant: basePrimaryVariant,
      secondary: baseSecondary,
      secondaryVariant: baseSecondaryVariant,
      background: baseBackground,
      surface: baseSurface,
      error: baseError,
      textOnPrimary: baseTextOnPrimary,
      textOnSecondary: baseTextOnSecondary,
      textOnBackground: baseTextOnBackground,
      textOnSurface: baseTextOnSurface,
      textOnError: baseTextOnError,
    ),
    'nightTheme': AppTheme(
      primary: ColorService.changeSaturation(Colors.blueGrey, 0.5),
      primaryVariant: ColorService.changeLightness(
          ColorService.changeSaturation(Colors.blueGrey, 0.5), 0.8),
      secondary: ColorService.changeSaturation(Colors.cyan, 0.5),
      secondaryVariant: ColorService.getComplementaryColor(
          ColorService.changeSaturation(Colors.cyan, 0.5)),
      background: Colors.grey[850]!,
      surface: Colors.grey[900]!,
      error: Colors.red[300]!,
      textOnPrimary: Colors.white,
      textOnSecondary: Colors.white,
      textOnBackground: Colors.white,
      textOnSurface: Colors.white,
      textOnError: Colors.black,
    ),
    'retroTheme': AppTheme(
      primary: ColorService.adjustHue(Colors.orange, -20),
      primaryVariant: ColorService.getTriadicColors(Colors.orange)[1],
      secondary: ColorService.adjustHue(Colors.teal, 20),
      secondaryVariant: ColorService.getTriadicColors(Colors.teal)[1],
      background: ColorService.changeSaturation(Colors.brown, 0.2),
      surface: ColorService.changeLightness(
          ColorService.changeSaturation(Colors.brown, 0.2), 0.5),
      error: Colors.deepOrange,
      textOnPrimary: Colors.white,
      textOnSecondary: Colors.black,
      textOnBackground: Colors.white,
      textOnSurface: Colors.black,
      textOnError: Colors.white,
    ),
    'aubergineTheme': AppTheme(
      primary: Color(0xFF5E3A87),
      primaryVariant: ColorService.changeLightness(Color(0xFF5E3A87), 0.5),
      secondary: Color(0xFFDE6FA1),
      secondaryVariant: ColorService.getComplementaryColor(Color(0xFFDE6FA1)),
      background: Color(0xFF2C1E4E),
      surface: Color(0xFF443D6D),
      error: Color(0xFFD32F2F),
      textOnPrimary: Colors.white,
      textOnSecondary: Colors.black,
      textOnBackground: Colors.white,
      textOnSurface: Colors.white,
      textOnError: Colors.white,
    ),
  };

  static String currentThemeKey = 'default';
  static AppTheme get currentTheme => availableThemes[currentThemeKey]!;
  static double currentFontSize = 24;

  static void switchTheme(String themeKey) {
    currentThemeKey = themeKey;
    print(themeKey);
    notify();
  }

  static void notify() {
    ThemeService().notifyListeners();
  }

  static void setFontSize(double newFontSize) {
    currentFontSize = newFontSize;
  }
}
