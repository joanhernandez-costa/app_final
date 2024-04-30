import 'package:app_final/services/MapService/MapStyleService.dart';
import 'package:flutter/material.dart';
import 'package:app_final/models/AppTheme.dart';

class ColorService {
  // Colores primarios
  static const Color primary = Color.fromRGBO(255, 166, 43, 1);
  static Color primaryVariant = changeLightness(primary, 0.5);

  // Colores secundarios
  static const Color secondary = Color.fromRGBO(22, 105, 122, 1);
  static Color secondaryVariant = getComplementaryColor(primaryVariant);

  // Colores de fondo
  static const Color background = Color.fromRGBO(130, 192, 204, 1);
  static const Color surface = Color.fromRGBO(72, 159, 181, 1);

  // Colores de error
  static const Color error = Color(0xFFB00020);

  // Colores de texto
  static const Color textOnPrimary = Color.fromRGBO(237, 231, 227, 1);
  static const Color textOnSecondary = Color.fromARGB(255, 0, 0, 0);
  static const Color textOnBackground = Color.fromARGB(255, 54, 54, 54);
  static const Color textOnSurface = Color(0xFF000000);
  static const Color textOnError = Color(0xFFFFFFFF);

  // Obtener un color con opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Cambiar el tono de un color y devolver el color modificado
  static Color adjustHue(Color color, double adjustment) {
    HSLColor hsl = HSLColor.fromColor(color);
    HSLColor adjustedHsl = hsl.withHue((hsl.hue + adjustment) % 360.0);
    return adjustedHsl.toColor();
  }

  // Cambiar la saturación de un color
  static Color changeSaturation(Color color, double saturationFactor) {
    HSLColor hsl = HSLColor.fromColor(color);
    double newSaturation = (hsl.saturation * saturationFactor).clamp(0.0, 1.0);
    HSLColor newHsl = hsl.withSaturation(newSaturation);
    return newHsl.toColor();
  }

  // Cambiar el brillo de un color
  static Color changeLightness(Color color, double lightnessFactor) {
    HSLColor hsl = HSLColor.fromColor(color);
    double newLightness = (hsl.lightness * lightnessFactor).clamp(0.0, 1.0);
    HSLColor newHsl = hsl.withLightness(newLightness);
    return newHsl.toColor();
  }

  // Devuelve los colores análogos
  static List<Color> getAnalogousColors(Color color) {
    return [
      adjustHue(color, -30),
      color,
      adjustHue(color, 30),
    ];
  }

  // Devuelve el color complementario
  static Color getComplementaryColor(Color color) {
    return adjustHue(color, 180);
  }

  // Devuelve la tríada complementaria al color
  static List<Color> getTriadicColors(Color color) {
    return [
      adjustHue(color, 120),
      color,
      adjustHue(color, 240),
    ];
  }
}
