import 'dart:math';
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:app_final/services/MapService/Utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShadowCastService {
  final SunPositionService sunService = SunPositionService();

  List<List<LatLng>> calculateIncrementalShadows(
      RestaurantData restaurant, DateTime localTime) {
    double heightIncrement = 2.0; // Incremento de altura en metros
    int numberOfLevels = (restaurant.detail.height! / heightIncrement).ceil();
    List<List<LatLng>> allShadows = [];

    for (int i = 0; i <= numberOfLevels; i++) {
      double currentHeight = i * heightIncrement;
      double solarElevation = sunService.getSunElevation(
          LatLng(restaurant.data.latitude, restaurant.data.longitude),
          localTime);
      double solarAzimuth = sunService.calculateSolarAzimuth(
          LatLng(restaurant.data.latitude, restaurant.data.longitude),
          localTime);
      double shadowLength =
          calculateShadowLength(currentHeight, solarElevation);
      double shadowDirection = calculateShadowDirection(solarAzimuth);
      List<LatLng> levelShadow = calculateShadowProjection(
          restaurant.detail.perimeterPoints!, shadowLength, shadowDirection);
      allShadows.add(levelShadow);
    }

    return allShadows;
  }

  List<LatLng> getShadow(RestaurantData restaurant, DateTime localTime) {
    List<List<LatLng>> incrementalShadows =
        calculateIncrementalShadows(restaurant, localTime);
    return mergeShadows(incrementalShadows);
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
      shadowPerimeter.add(shadowPoint);
    }

    return shadowPerimeter;
  }

  List<LatLng> mergeShadows(List<List<LatLng>> allShadows) {
    List<LatLng> allPoints = allShadows.expand((x) => x).toList();
    return convexHull(allPoints);
  }

  List<LatLng> convexHull(List<LatLng> points) {
    if (points.length < 3) return points;
    points.sort((p1, p2) => (p1.latitude != p2.latitude)
        ? p1.latitude.compareTo(p2.latitude)
        : p1.longitude.compareTo(p2.longitude));

    List<LatLng> hull = [points.removeAt(0), points.removeAt(0)];
    points.forEach((point) {
      while (hull.length > 1 &&
          orientation(hull[hull.length - 2], hull.last, point) <= 0) {
        hull.removeLast();
      }
      hull.add(point);
    });

    return hull;
  }

  double orientation(LatLng p, LatLng q, LatLng r) {
    return (q.latitude - p.latitude) * (r.longitude - q.longitude) -
        (q.longitude - p.longitude) * (r.latitude - q.latitude);
  }

  double calculateShadowLength(double height, double solarElevation) {
    return height * tan(Utils.degreesToRadians(90 - solarElevation));
  }

  double calculateShadowDirection(double solarAzimuth) {
    return Utils.degreesToRadians(solarAzimuth + 180) % (2 * pi);
  }
}
