import 'dart:math';
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:app_final/services/MapService/Utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShadowCastService {
  final SunPositionService sunService = SunPositionService();

  /// Calcula las sombras arrojadas por cada una de las plantas de un restaurante
  /// basado en la altura de la planta, su perímetro y la posición del sol en un momento dado.
  ///
  /// [restaurant]: Datos del restaurante.
  /// [localTime]: Tiempo local para el cálculo de la sombra.
  ///
  /// Devuelve una lista de LatLng que representan los perímetros
  /// de las sombras arrojadas por las diferentes plantas del edificio.
  List<List<LatLng>> calculateIncrementalShadows(
      RestaurantData restaurant, DateTime localTime) {
    double heightIncrement = 2; // Incremento de altura en metros
    int numberOfLevels = (restaurant.detail.height! / heightIncrement).ceil();

    LatLng restaurantPosition =
        LatLng(restaurant.data.latitude, restaurant.data.longitude);
    double solarElevation = sunService.getSunElevation(
      restaurantPosition,
      localTime,
    );
    double solarAzimuth = sunService.calculateSolarAzimuth(
      restaurantPosition,
      localTime,
    );
    double shadowDirection = calculateShadowDirection(solarAzimuth);

    List<List<LatLng>> allShadows = [];

    for (int i = 0; i <= numberOfLevels; i++) {
      double currentHeight = i * heightIncrement;
      double shadowLength =
          calculateShadowLength(currentHeight, solarElevation);

      List<LatLng> levelShadow = calculateShadowProjection(
          restaurant.detail.perimeterPoints!, shadowLength, shadowDirection);
      allShadows.add(levelShadow);
    }

    return allShadows;
  }

  /// Obtiene la sombra final de un restaurante en un momento dado.
  ///
  /// [restaurant]: Datos del restaurante.
  /// [localTime]: Hora local.
  ///
  /// Devuelve una lista de LatLng que representa el perímetro de la sombra final.
  List<LatLng> getShadow(RestaurantData restaurant, DateTime localTime) {
    List<List<LatLng>> incrementalShadows =
        calculateIncrementalShadows(restaurant, localTime);
    return mergeShadows(incrementalShadows);
  }

  /// Calcula la proyección de la sombra de un edificio en base a la longitud
  /// y dirección de la sombra.
  ///
  /// [perimeterPoints]: Lista de puntos que definen el perímetro del edificio.
  /// [shadowLength]: Longitud de la sombra.
  /// [shadowDirection]: Dirección de la sombra en grados.
  ///
  /// Devuelve una lista de puntos LatLng que representa el perímetro de la sombra
  List<LatLng> calculateShadowProjection(List<LatLng> perimeterPoints,
      double shadowLength, double shadowDirection) {
    List<LatLng> shadowPerimeter = [];
    const double metersPerDegreeLatitude = 111000;
    double directionInRadians = Utils.degreesToRadians(shadowDirection);

    for (var basePoint in perimeterPoints) {
      double deltaLatitude =
          (shadowLength * cos(directionInRadians)) / metersPerDegreeLatitude;
      double deltaLongitude = (shadowLength * sin(directionInRadians)) /
          (metersPerDegreeLatitude *
              cos(Utils.degreesToRadians(basePoint.latitude)));

      double shadowPointLatitude = basePoint.latitude + deltaLatitude;
      double shadowPointLongitude = basePoint.longitude + deltaLongitude;

      LatLng shadowPoint = LatLng(shadowPointLatitude, shadowPointLongitude);
      shadowPerimeter.add(shadowPoint);
    }

    return shadowPerimeter;
  }

  /// Combina las sombras incrementales en una sola envolvente.
  ///
  /// [allShadows]: Lista de listas de puntos LatLng que representan las sombras incrementales.
  /// Devuelve una lista de puntos LatLng que representan la envolvente convexa.
  List<LatLng> mergeShadows(List<List<LatLng>> allShadows) {
    List<LatLng> allPoints = allShadows.expand((x) => x).toList();
    return convexHull(allPoints);
  }

  /// Calcula la envolvente convexa de un conjunto de puntos utilizando el algoritmo de Graham scan.
  ///
  /// [points]: Nube de puntos LatLng.
  /// Devuelve una lista de puntos LatLng que representan la envolvente de esa nube.
  List<LatLng> convexHull(List<LatLng> points) {
    if (points.length < 3) return points;
    points.sort((p1, p2) => (p1.latitude != p2.latitude)
        ? p1.latitude.compareTo(p2.latitude)
        : p1.longitude.compareTo(p2.longitude));

    List<LatLng> hull = [];

    // Función de ayuda para determinar la orientación
    int orientation(LatLng p, LatLng q, LatLng r) {
      double val = (q.longitude - p.longitude) * (r.latitude - q.latitude) -
          (q.latitude - p.latitude) * (r.longitude - q.longitude);
      if (val == 0) return 0;
      return (val > 0) ? 1 : -1;
    }

    // Construir la envolvente inferior
    for (var point in points) {
      while (hull.length >= 2 &&
          orientation(hull[hull.length - 2], hull[hull.length - 1], point) !=
              -1) {
        hull.removeLast();
      }
      hull.add(point);
    }

    // Construir la envolvente superior
    int t =
        hull.length + 1; // Tamaño del hull antes de procesar el lado superior
    for (int i = points.length - 2; i >= 0; i--) {
      while (hull.length >= t &&
          orientation(
                  hull[hull.length - 2], hull[hull.length - 1], points[i]) !=
              -1) {
        hull.removeLast();
      }
      hull.add(points[i]);
    }

    hull.removeLast();
    return hull;
  }

  /// Calcula la longitud de la sombra basada en la altura y la elevación solar.
  ///
  /// [height]: Altura del objeto que proyecta la sombra.
  /// [solarElevation]: Elevación solar en grados.
  /// Devuelve la longitud de la sombra en metros.
  double calculateShadowLength(double height, double solarElevation) {
    double solarElevationRadians = Utils.degreesToRadians(solarElevation);

    if (solarElevationRadians == 0) {
      return double.infinity;
      // La sombra es 'infinita' cuando la elevación solar es 0.
    }

    return height / tan(solarElevationRadians);
  }

  /// Calcula la dirección de la sombra basada en el azimut solar.
  ///
  /// [solarAzimuth]: Azimut solar en grados.
  /// Devuelve la dirección en grados. Norte -> 0º, Este -> 90º...
  double calculateShadowDirection(double solarAzimuth) {
    /*double shadowDirection = (solarAzimuth - 180) % 360;
    return shadowDirection;*/
    return (solarAzimuth + 360) % 360;
  }

  /// Determina si un punto está dentro de un polígono o no.
  ///
  /// [point]: Punto LatLng a comprobar.
  /// [polygon]: Lista de puntos LatLng que definen el polígono.
  /// Devuelve 'true' si el punto está dentro del polígono, 'false' de lo contrario.
  bool isRestaurantInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      LatLng v1 = polygon[j];
      LatLng v2 = polygon[j + 1];
      if ((v1.latitude > point.latitude) != (v2.latitude > point.latitude) &&
          (point.longitude <
              (v2.longitude - v1.longitude) *
                      (point.latitude - v1.latitude) /
                      (v2.latitude - v1.latitude) +
                  v1.longitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  /// Determina si un restaurante está a la luz del sol en un momento dado.
  ///
  /// [restaurant]: Datos del restaurante.
  /// [localTime]: Tiempo local para el cálculo de la sombra.
  /// Devuelve 'true' si el restaurante está a la luz del sol, 'false' de lo contrario.
  bool isRestaurantInSunLight(RestaurantData restaurant, DateTime localTime) {
    List<LatLng> shadowPolygon = getShadow(restaurant, localTime);
    return !isRestaurantInPolygon(
        LatLng(restaurant.data.latitude, restaurant.data.longitude),
        shadowPolygon);
  }
}
