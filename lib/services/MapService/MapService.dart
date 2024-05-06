import 'dart:math';

import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/MapService/MapStyleService.dart';
import 'package:app_final/services/MapService/ShadowCastService.dart';
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:app_final/services/ThemeService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  GoogleMapController? mapController;
  CameraPosition? currentCameraPosition;
  MapStyleService mapStyle = MapStyleService();
  ShadowCastService shadowService = ShadowCastService();

  LatLngBounds? visibleRegion;
  DateTime? selectedTime;
  Set<Marker> markers = <Marker>{};
  Set<Polygon> polygons = <Polygon>{};

  Function(Set<Marker>) onMarkersUpdated;
  Function(Set<Polygon>) onPolygonsUpdated;
  Function(Set<Circle>) onCirclesUpdated;
  dynamic Function(RestaurantData)? onMarkerTapped;

  MapService(
      {required this.onMarkersUpdated,
      required this.onPolygonsUpdated,
      required this.onCirclesUpdated});

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  void updateCameraPosition(CameraPosition newCameraPosition) {
    currentCameraPosition = newCameraPosition;
  }

  // Mover el mapa a una nueva posición
  void move(LatLng newPosition) {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(newPosition, 16),
    );
  }

  // Función para crear un cuadrado en el mapa
  Polygon drawSquare(LatLng centerPosition, double sideLength) {
    const double latDegree = 110574;
    final double lngDegree = 111320 * cos(centerPosition.latitude * pi / 180);

    double halfSideLat = (sideLength / 2) / latDegree;
    double halfSideLng = (sideLength / 2) / lngDegree;

    List<LatLng> squarePerimeter = [
      LatLng(centerPosition.latitude + halfSideLat,
          centerPosition.longitude - halfSideLng),
      LatLng(centerPosition.latitude + halfSideLat,
          centerPosition.longitude + halfSideLng),
      LatLng(centerPosition.latitude - halfSideLat,
          centerPosition.longitude + halfSideLng),
      LatLng(centerPosition.latitude - halfSideLat,
          centerPosition.longitude - halfSideLng),
    ];

    final String polygonIdVal =
        'square_${centerPosition.latitude}_${centerPosition.longitude}';
    final PolygonId polygonId = PolygonId(polygonIdVal);

    final Polygon square = Polygon(
      polygonId: polygonId,
      points: squarePerimeter,
      fillColor: Colors.green.withOpacity(0.5),
      strokeColor: Colors.black,
      strokeWidth: 3,
      zIndex: 2,
      geodesic: true,
    );

    return square;
  }

  // Función para crear un círculo en el mapa
  Circle drawCircle(LatLng center, double radius, Color fillColor) {
    final String circleIdVal = 'circle_${center.latitude}_${center.longitude}';
    final CircleId circleId = CircleId(circleIdVal);

    final Circle circle = Circle(
      circleId: circleId,
      center: center,
      radius: radius,
      fillColor: fillColor.withOpacity(0.5),
      strokeColor: Colors.black,
      strokeWidth: 2,
      zIndex: 2,
    );

    return circle;
  }

  //Crea un polígono para mostrarlo en el mapa
  Polygon drawShadowPolygon(RestaurantData restaurant, DateTime time) {
    List<LatLng> shadowPerimeter = shadowService.getShadow(restaurant, time);
    shadowPerimeter.add(shadowPerimeter.first);

    return Polygon(
      polygonId: PolygonId('shadow_${restaurant.data.id}_$time'),
      points: shadowPerimeter,
      fillColor: ThemeService.currentTheme.secondary.withOpacity(0.3),
      strokeColor: Colors.black,
      strokeWidth: 2,
      zIndex: 1,
      geodesic: true,
    );
  }

  Polygon drawPerimeterPolygon(RestaurantData restaurant) {
    return Polygon(
      polygonId: PolygonId('perimeter_${restaurant.data.id}'),
      points: restaurant.detail.perimeterPoints!,
      fillColor: ThemeService.currentTheme.primary.withOpacity(0.5),
      strokeColor: Colors.black,
      strokeWidth: 2,
      zIndex: 1,
    );
  }

  // Agregar un marcador de Punto de Interés (POI)
  Marker addPOIMarker(RestaurantData restaurant) {
    LatLng restaurantPosition =
        LatLng(restaurant.data.latitude, restaurant.data.longitude);
    bool isInSunLight = SunPositionService.isRestaurantInSunLight(
        restaurantPosition, DateTime.now());

    final String markerIdVal =
        'marker_${restaurant.data.latitude}_${restaurant.data.longitude}';
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
        markerId: markerId,
        position: restaurantPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(isInSunLight
            ? BitmapDescriptor.hueOrange
            : BitmapDescriptor.hueBlue),
        onTap: () {
          if (onMarkerTapped != null) {
            onMarkerTapped!(restaurant);
          }
        });

    return marker;
  }

  void onCameraIdle() async {
    // Obtiene el zoom del mapa
    var zoom = await mapController?.getZoomLevel();
    visibleRegion = await mapController!.getVisibleRegion();

    if (zoom! > 15) {
      loadMarkers();
      loadPolygons();
      //loadCircles();
    } else {
      // Eliminar los marcadores si el zoom es demasiado bajo
      removeMarkers();
      removePolygons();
    }
  }

  void loadCircles() async {
    if (mapController == null) return;

    visibleRegion = await mapController!.getVisibleRegion();
    Set<Circle> circles = {};

    Color baseColor = ThemeService.currentTheme.primary;
    double hueAdjustment = 0;

    for (var restaurant in RestaurantData.allRestaurantsData) {
      LatLng restaurantLocation =
          LatLng(restaurant.data.latitude, restaurant.data.longitude);

      hueAdjustment += 20;
      Color restaurantColor = ColorService.adjustHue(baseColor, hueAdjustment);

      if (visibleRegion!.contains(restaurantLocation) &&
          restaurant.detail.perimeterPoints != null) {
        for (var basePoint in restaurant.detail.perimeterPoints!) {
          Circle circle = drawCircle(basePoint, 2.5, restaurantColor);
          circles.add(circle);
        }
      }
    }
    onCirclesUpdated(circles);
  }

  void loadPolygons() async {
    if (mapController == null) return;

    LatLngBounds visibleRegion = await mapController!.getVisibleRegion();
    this.visibleRegion = visibleRegion;

    updateShadows();
    //updateIncrementalShadows();
    onPolygonsUpdated(polygons);
  }

  void loadMarkers() async {
    markers.clear();

    visibleRegion = await mapController?.getVisibleRegion();
    if (visibleRegion == null) return;

    for (var restaurant in RestaurantData.allRestaurantsData) {
      LatLng restaurantLocation =
          LatLng(restaurant.data.latitude, restaurant.data.longitude);

      if (visibleRegion!.contains(restaurantLocation)) {
        Marker marker = addPOIMarker(restaurant);
        markers.add(marker);
      }
    }

    onMarkersUpdated(markers);
  }

  void updateShadows() async {
    if (mapController == null) return;

    polygons.clear();

    for (var restaurant in RestaurantData.allRestaurantsData) {
      LatLng position =
          LatLng(restaurant.data.latitude, restaurant.data.longitude);
      if (visibleRegion?.contains(position) ?? false) {
        polygons
          ..add(drawShadowPolygon(restaurant, selectedTime!))
          ..add(drawPerimeterPolygon(restaurant));
      }
    }

    onPolygonsUpdated(polygons);
  }

  void updateIncrementalShadows() async {
    if (mapController == null) return;

    visibleRegion = await mapController!.getVisibleRegion();
    Set<Polygon> newShadows = {};

    polygons.removeWhere(
        (polygon) => polygon.polygonId.value.startsWith('shadow_'));

    for (var restaurant in RestaurantData.allRestaurantsData) {
      LatLng position =
          LatLng(restaurant.data.latitude, restaurant.data.longitude);
      if (visibleRegion!.contains(position) &&
          restaurant.detail.perimeterPoints != null) {
        List<List<LatLng>> shadows = shadowService.calculateIncrementalShadows(
            restaurant, selectedTime!);
        for (int i = 0; i < shadows.length; i++) {
          Polygon shadowPolygon = Polygon(
            polygonId: PolygonId('shadow_${restaurant.data.id}_level_$i'),
            points: shadows[i],
            fillColor: ThemeService.currentTheme.secondary
                .withOpacity(0.1 + (0.8 / shadows.length * i)),
            strokeColor: Colors.black,
            strokeWidth: 2,
            zIndex: 1,
            geodesic: true,
          );
          newShadows.add(shadowPolygon);
        }

        polygons
          ..addAll(newShadows)
          ..add(drawPerimeterPolygon(restaurant));
        newShadows.clear();
      }
    }

    onPolygonsUpdated(polygons);
  }

  void setSelectedTime(DateTime selectedTime) {
    this.selectedTime = selectedTime;
  }

  void removePolygons() {
    polygons.clear();
    onPolygonsUpdated(polygons);
  }

  void removeMarkers() {
    markers.clear();
    onMarkersUpdated(markers);
  }

  void enable3DView() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: currentCameraPosition!.bearing,
          target: currentCameraPosition!.target,
          zoom: currentCameraPosition!.zoom,
          tilt: 45.0, // Inclinación en grados para la vista 3D
        ),
      ),
    );
  }

  // Deshabilitar la vista en 3D y volver a la vista normal
  void disable3DView() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: currentCameraPosition!.bearing,
          target: currentCameraPosition!.target,
          zoom: currentCameraPosition!.zoom,
          tilt: 0.0, // Inclinación en grados para la vista normal
        ),
      ),
    );
  }

  void toggle3DView() {
    if (currentCameraPosition?.tilt == 0) {
      enable3DView();
    } else {
      disable3DView();
    }
  }

  double getMapRotation() {
    return currentCameraPosition?.bearing ?? 0;
  }

  void setStyle() async {
    MapStyle style = MapStyleService.mapStyleFromTime(selectedTime!);
    String styleJson = await MapStyleService.getJsonStyle(style);
    mapController!.setMapStyle(styleJson);
    MapStyleService.updateTheme();
  }
}
