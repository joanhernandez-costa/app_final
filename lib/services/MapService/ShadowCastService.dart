import 'dart:math';
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:app_final/services/MapService/Utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShadowCastService {
  final SunPositionService sunService = SunPositionService();

  List<LatLng> projectShadow(RestaurantData restaurant, DateTime localTime) {
    LatLng restaurantPosition =
        LatLng(restaurant.data.latitude, restaurant.data.longitude);

    double solarElevation =
        sunService.getSunElevation(restaurantPosition, localTime);
    double solarAzimuth =
        sunService.calculateSolarAzimuth(restaurantPosition, localTime);

    double shadowLength =
        calculateShadowLength(restaurant.detail.height!, solarElevation);
    double shadowDirection = calculateShadowDirection(solarAzimuth);

    List<LatLng> shadowPerimeter = calculateShadowProjection(
        restaurant.detail.perimeterPoints!, shadowLength, shadowDirection);

    return shadowPerimeter;
  }

  List<LatLng> calculateShadowProjection(List<LatLng> perimeterPoints,
      double shadowLength, double shadowDirection) {
    List<LatLng> shadowPerimeter = [];
    const double metersPerDegreeLatitude = 111000;

    for (var basePoint in perimeterPoints) {
      double deltaLatitude =
          (shadowLength * cos(shadowDirection)) / metersPerDegreeLatitude;
      double deltaLongitude = (shadowLength * sin(shadowDirection)) /
          (metersPerDegreeLatitude * cos(basePoint.latitude * pi / 180));

      double shadowPointLatitude = basePoint.latitude + deltaLatitude;
      double shadowPointLongitude = basePoint.longitude + deltaLongitude;

      LatLng shadowPoint = LatLng(shadowPointLatitude, shadowPointLongitude);
      print(
          'newShadowPoint: ${shadowPoint.latitude}, ${shadowPoint.longitude}');
      shadowPerimeter.add(shadowPoint);
    }

    return shadowPerimeter;
  }

  double calculateShadowLength(double height, double solarElevation) {
    return height * tan(Utils.degreesToRadians(90 - solarElevation));
  }

  double calculateShadowDirection(double solarAzimuth) {
    return Utils.degreesToRadians(solarAzimuth + 180) % (2 * pi);
  }
}
