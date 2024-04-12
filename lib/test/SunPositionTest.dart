
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test/test.dart';

void main() {
  group('SunPositionService', () {
    int failedTests = 0;
    int totalTests = 0;

    // Función auxiliar para realizar y evaluar el test, incrementando los contadores según corresponda
    void performTest(String testName, Function testBody) {
      totalTests++;
      try {
        testBody();
        print('$testName: PASSED');
      } catch (e) {
        failedTests++;
        print('$testName: FAILED - $e');
      }
    }

    // Test para probar el azimuth solar en una fecha conocida, con una tolerancia de 5 grados
    test('Azimuth solar en una fecha conocida', () {
      final service = SunPositionService();
      const position = LatLng(40.7128, -74.0060); // Ejemplo: Nueva York
      final localTime = DateTime.utc(2022, 6, 21, 12, 0); // Fecha conocida, por ejemplo, el solsticio de verano

      final azimuth = service.calculateSolarAzimuth(position, localTime);

      // Se espera un valor específico con una tolerancia de 5 grados
      expect(azimuth, closeTo(180, 5));
    });

    // Test para probar la elevación solar en una fecha conocida, con una tolerancia de 5 grados
    test('Elevación solar en una fecha conocida', () {
      final service = SunPositionService();
      const position = LatLng(40.7128, -74.0060); // Ejemplo: Nueva York
      final localTime = DateTime.utc(2022, 6, 21, 12, 0); // Fecha conocida, por ejemplo, el solsticio de verano

      final elevation = service.getSunElevation(position, localTime);

      // Se espera un valor específico con una tolerancia de 5 grados
      expect(elevation, closeTo(75, 5));
    });

    // Test para probar la consistencia del azimuth solar a lo largo de un día completo
    test('Consistencia del azimuth solar a lo largo de un día', () {
      final service = SunPositionService();
      const position = LatLng(40.7128, -74.0060); // Ejemplo: Nueva York
      var previousAzimuth = service.calculateSolarAzimuth(position, DateTime.utc(2022, 6, 21, 0, 0));

      for (int hour = 1; hour <= 24; hour++) {
        final currentAzimuth = service.calculateSolarAzimuth(position, DateTime.utc(2022, 6, 21, hour, 0));
        if (hour < 24) {
          expect(currentAzimuth, closeTo(previousAzimuth, 20)); // La variación del azimuth entre horas debe ser menor a 20.
        } else {
          expect(currentAzimuth, closeTo(previousAzimuth, 10)); // A la hora 24 debe ser muy similar a la hora 0
        }
        previousAzimuth = currentAzimuth;
      }
    });

    // Test para probar la consistencia de la elevación solar a lo largo de un día completo
    test('Consistencia de la elevación solar a lo largo de un día', () {
      final service = SunPositionService();
      const position = LatLng(40.7128, -74.0060); // Ejemplo: Nueva York
      var previousElevation = service.getSunElevation(position, DateTime.utc(2022, 6, 21, 0, 0));

      for (int hour = 1; hour <= 24; hour++) {
        final currentElevation = service.getSunElevation(position, DateTime.utc(2022, 6, 21, hour, 0));
        print('$hour: $currentElevation');
        if (hour < 24) {
          expect(currentElevation, closeTo(previousElevation, 20)); // La variación del azimuth entre horas debe ser menor a 20.
        } else {
          expect(currentElevation, closeTo(previousElevation, 10)); // A la hora 24 debe ser muy similar a la hora 0
        }
        previousElevation = currentElevation;
      }
    });

    // Al final de todos los tests, reportamos el resumen de los resultados
    tearDown(() {
      if (failedTests > 0) {
        print('Tests finished with $failedTests failures out of $totalTests tests.');
      } else {
        print('All $totalTests tests passed successfully!');
      }
    });
  });
}