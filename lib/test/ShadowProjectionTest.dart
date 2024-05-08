import 'package:apsl_sun_calc/apsl_sun_calc.dart';
import 'package:test/test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_final/services/MapService/ShadowCastService.dart';

void main() {
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
        var solarAzimuth =
            shadows.sunService.calculateSolarAzimuth(LatLng(lat, lon), current);
        var shadowDirectionDegrees =
            shadows.calculateShadowDirection(solarAzimuth);

        var solarElevation =
            shadows.sunService.getSunElevation(LatLng(lat, lon), current);
        var shadowLength = shadows.calculateShadowLength(20, solarElevation);

        // Se imprimen los valores para comprobar.
        print('Time: $current');
        print('Solar Azimuth: $solarAzimuth');
        print('Shadow Direction: $shadowDirectionDegrees');

        print('Solar Elevation: $solarElevation');
        print('Shadow length: $shadowLength');

        print('---------------');

        // Aumentar la hora actual en 60 minutos.
        current = current.add(const Duration(minutes: 60));
      }
    });
  });
}
