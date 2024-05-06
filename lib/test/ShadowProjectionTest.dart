import 'dart:math';
import 'package:apsl_sun_calc/apsl_sun_calc.dart';
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

  group('ShadowCastService Test', () {
    test('Posiciones solares desde el amanecer hasta atardecer', () async {
      final shadows = ShadowCastService();
      double lat = 40.44909830960289;
      double lon = -3.7121435091200987;
      DateTime date = DateTime.now();

      // Se obtiene sunrise y sunset utilizando SunCalc
      var times = await SunCalc.getTimes(date, lat, lon);
      DateTime sunrise = times['sunrise']!.toLocal();
      DateTime sunset = times['sunset']!.toLocal();

      // Probar valores desde el amanecer hasta el atardecer
      DateTime current = sunrise;
      while (current.isBefore(sunset)) {
        var sunPosition = SunCalc.getSunPosition(current, lat, lon);

        var solarAzimuth =
            shadows.sunService.calculateSolarAzimuth(LatLng(lat, lon), current);
        var solarElevation =
            shadows.sunService.getSunElevation(LatLng(lat, lon), current);
        var shadowDirectionDegrees = Utils.radiansToDegrees(
            shadows.calculateShadowDirection(solarAzimuth));

        // Se imprimen los valores para comprobar.
        print('Time: $current');
        print('Solar Azimuth: ${sunPosition['azimuth']}');
        print('Solar Elevation: ${sunPosition['altitude']}');
        //print('Shadow Direction: $shadowDirectionDegrees');

        // Aumentar la hora actual en 60 minutos.
        current = current.add(const Duration(minutes: 60));
      }
    });
  });
}
