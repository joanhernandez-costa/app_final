import 'package:flutter/material.dart';

class ColorService {
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
