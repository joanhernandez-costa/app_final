import 'dart:math';
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:app_final/services/MapService/Utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShadowCastService {
  final SunPositionService sunService = SunPositionService();

  Future<List<LatLng>> projectShadow(RestaurantData restaurant, DateTime localTime) async {
    LatLng restaurantPosition = LatLng(restaurant.data.latitude, restaurant.data.longitude);

    double solarElevation = sunService.getSunElevation(restaurantPosition, localTime);
    double solarAzimuth = sunService.calculateSolarAzimuth(restaurantPosition, localTime);

    List<LatLng> shadowPerimeter = calculateShadowProjection(restaurant.detail.perimeterPoints!, restaurant.detail.height!, solarAzimuth, solarElevation);

    return shadowPerimeter;
  }

  List<LatLng> calculateShadowProjection(List<LatLng> perimeterPoints, double height, double solarAzimuth, double solarElevation) {
    List<LatLng> shadowPerimeter = [];
    double shadowLength = height * tan(Utils.degreesToRadians(90 - solarElevation));
    double shadowDirection = Utils.degreesToRadians(solarAzimuth + 180) % (2 * pi);

    for (var point in perimeterPoints) {
      double shadowPointLatitude = point.latitude + shadowLength * cos(shadowDirection);
      double shadowPointLongitude = point.longitude + shadowLength * sin(shadowDirection);

      shadowPerimeter.add(LatLng(shadowPointLatitude, shadowPointLongitude));
    }

    return shadowPerimeter;
  }

}
