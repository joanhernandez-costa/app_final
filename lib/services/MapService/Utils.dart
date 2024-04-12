
import 'dart:math';
import 'package:flutter/services.dart';

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

  static Future<Uint8List> loadFileAsUint8List(String assetPathToFile) async {
    // The path refers to the assets directory as specified in pubspec.yaml.
    ByteData fileData = await rootBundle.load(assetPathToFile);
    return Uint8List.view(fileData.buffer);
  }

}