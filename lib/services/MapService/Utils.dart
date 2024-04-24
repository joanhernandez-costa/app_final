import 'dart:math';

class Utils {
  // Convierte de grados a radianes.
  static double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Convierte de radianes a grados.
  static double radiansToDegrees(double radians) {
    return radians * (180 / pi);
  }

  // Devuelve un número aleatorio en un rango indicado.
  static double getRandom(double min, double max) {
    return min + Random().nextDouble() * (max - min);
  }
}
