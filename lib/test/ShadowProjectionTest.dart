import 'dart:math';
import 'package:test/test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_final/services/MapService/ShadowCastService.dart';
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/MapService/Utils.dart';

void main() {
  double calculateDistance(LatLng start, LatLng end) {
    var earthRadius = 6371000.0; // Radio de la Tierra en metros
    var dLat = Utils.degreesToRadians(end.latitude - start.latitude);
    var dLon = Utils.degreesToRadians(end.longitude - start.longitude);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(Utils.degreesToRadians(start.latitude)) *
            cos(Utils.degreesToRadians(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var distance = earthRadius * c;
    return distance;
  }

  group('ShadowCastService Tests', () {
    test('Shadow projection accuracy', () {
      // Crear una instancia del servicio y los datos necesarios para la prueba
      final shadowService = ShadowCastService();
      final RestaurantData restaurant = RestaurantData.allRestaurantsData[0];
      final DateTime localTime =
          DateTime.now(); // Fecha de ejemplo, como el solsticio de verano

      // Llamada al método del servicio para obtener el perímetro de la sombra
      List<LatLng> shadowPerimeter =
          shadowService.projectShadow(restaurant, localTime);

      for (var i = 0; i < restaurant.detail.perimeterPoints!.length; i++) {
        var originalPoint = restaurant.detail.perimeterPoints![i];
        var shadowPoint = shadowPerimeter[i];

        // Calcular la distancia esperada usando la altura y la elevación solar
        double solarElevation = shadowService.sunService.getSunElevation(
            LatLng(originalPoint.latitude, originalPoint.longitude), localTime);
        double shadowLength = restaurant.detail.height! *
            tan(Utils.degreesToRadians(90 - solarElevation));

        // Calcular la distancia real entre el punto original y el punto de la sombra
        double calculatedDistance =
            calculateDistance(originalPoint, shadowPoint);

        // Verificar si la distancia calculada está cerca de la distancia esperada, con una tolerancia pequeña para errores de cálculo
        expect(calculatedDistance,
            closeTo(shadowLength, 1.0)); // Tolerancia de 1 metro
      }
    });
  });
}
