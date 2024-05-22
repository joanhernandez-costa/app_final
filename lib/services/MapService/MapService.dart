import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/MapService/MapStyleService.dart';
import 'package:app_final/services/MapService/ShadowCastService.dart';
import 'package:app_final/services/ThemeService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:collection/collection.dart';

class MapService {
  GoogleMapController? mapController;
  CameraPosition? currentCameraPosition;
  MapStyleService mapStyle = MapStyleService();
  ShadowCastService shadowService = ShadowCastService();

  LatLngBounds? visibleRegion;
  DateTime? selectedTime;
  Set<Marker> markers = <Marker>{};
  Set<Polygon> polygons = <Polygon>{};
  Map<String, bool> markerSunlightStatus = {};

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
  Future<void> move(LatLng newPosition) async {
    await initShowAnimation(newPosition);
  }

  Future<void> onCameraIdle() async {
    if (mapController == null) return;
    // Obtiene el zoom del mapa
    var zoom = await mapController?.getZoomLevel();
    visibleRegion = await mapController!.getVisibleRegion();

    if (zoom! > 15) {
      await updateVisibleMarkers();
      await loadPolygons();
      //await loadIncrementalShadows();
      //loadCircles();
    } else {
      // Eliminar los marcadores si el zoom es demasiado bajo
      removeMarkers();
      removePolygons();
    }
  }

  Future<void> updateVisibleMarkers() async {
    if (mapController == null || visibleRegion == null) return;

    Set<Marker> newMarkers = {};

    List<RestaurantData> visibleRestaurants =
        RestaurantData.allRestaurantsData.where((restaurant) {
      LatLng restaurantLocation =
          LatLng(restaurant.data.latitude, restaurant.data.longitude);
      return visibleRegion!.contains(restaurantLocation);
    }).toList();

    for (var restaurant in visibleRestaurants) {
      String markerIdVal =
          'marker_${restaurant.data.latitude}_${restaurant.data.longitude}';
      bool isInSunLight =
          shadowService.isRestaurantInSunLight(restaurant, selectedTime!);

      // Solo se actualiza el marcador si el estado de sombra o sol ha cambiado.
      if (markerSunlightStatus[markerIdVal] != isInSunLight) {
        Marker marker = await addPOIMarker(restaurant);
        newMarkers.add(marker);
      } else {
        // Si no ha cambiado el estado, se mantiene el marcador.
        Marker? existingMarker = markers
            .firstWhereOrNull((marker) => marker.markerId.value == markerIdVal);

        if (existingMarker != null) {
          newMarkers.add(existingMarker);
        }
      }
    }
    markers = newMarkers;
    onMarkersUpdated(markers);
  }

  // Agregar un marcador de Punto de Interés (POI)
  Future<Marker> addPOIMarker(RestaurantData restaurant) async {
    LatLng restaurantPosition =
        LatLng(restaurant.data.latitude, restaurant.data.longitude);
    bool isInSunLight =
        shadowService.isRestaurantInSunLight(restaurant, selectedTime!);

    final String markerIdVal =
        'marker_${restaurant.data.latitude}_${restaurant.data.longitude}';
    final MarkerId markerId = MarkerId(markerIdVal);

    Color iconColor = isInSunLight
        ? ThemeService.currentTheme.primary
        : ThemeService.currentTheme.secondary;
    Color backgroundColor = isInSunLight
        ? ThemeService.currentTheme.secondary
        : ThemeService.currentTheme.primary;
    IconData icon = isInSunLight ? Icons.wb_sunny : Icons.cloud;

    Uint8List iconData =
        await createCustomMarkerBitmap(icon, iconColor, backgroundColor, 100);

    final Marker marker = Marker(
        markerId: markerId,
        position: restaurantPosition,
        icon: BitmapDescriptor.fromBytes(iconData),
        onTap: () {
          if (onMarkerTapped != null) {
            onMarkerTapped!(restaurant);
          }
        });

    markerSunlightStatus[markerIdVal] = isInSunLight;

    return marker;
  }

  Future<Uint8List> createCustomMarkerBitmap(
      IconData icon, Color color, Color backgroundColor, int size) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double iconSize = size.toDouble();
    const double padding = 15.0;
    final double circleRadius = iconSize / 2 + padding;

    final double canvasSize = iconSize + padding * 2;

    final Paint paint = Paint()..color = backgroundColor;
    canvas.drawCircle(
        Offset(canvasSize / 2, canvasSize / 2), circleRadius, paint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    )
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          color: color,
        ),
      )
      ..layout();

    final double iconOffset = (canvasSize - textPainter.width) / 2;
    textPainter.paint(canvas, Offset(iconOffset, iconOffset));
    final img = await pictureRecorder
        .endRecording()
        .toImage(canvasSize.toInt(), canvasSize.toInt());
    final ByteData? byteData =
        await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> loadPolygons() async {
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

  //Crea un polígono para mostrarlo en el mapa
  Polygon drawShadowPolygon(RestaurantData restaurant, DateTime time) {
    List<LatLng> shadowPerimeter = shadowService.getShadow(restaurant, time);
    //shadowPerimeter.add(shadowPerimeter.first);

    return Polygon(
      polygonId: PolygonId('shadow_${restaurant.data.id}_$time'),
      points: shadowPerimeter,
      fillColor: ThemeService.currentTheme.secondary.withOpacity(0.3),
      strokeColor: Colors.black,
      strokeWidth: 2,
      zIndex: 0,
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

  Future<void> loadIncrementalShadows() async {
    if (mapController == null) return;

    for (var restaurant in RestaurantData.allRestaurantsData) {
      LatLng position =
          LatLng(restaurant.data.latitude, restaurant.data.longitude);
      if (visibleRegion?.contains(position) ?? false) {
        List<List<LatLng>> shadows = ShadowCastService()
            .calculateIncrementalShadows(restaurant, selectedTime!);
        for (int i = 0; i < shadows.length; i++) {
          Polygon shadowPolygon = Polygon(
            polygonId: PolygonId('shadow_${restaurant.data.id}_level_$i'),
            points: shadows[i],
            fillColor: ThemeService.currentTheme.secondary
                .withOpacity(0.1 + (0.8 / shadows.length * i)),
            strokeColor: Colors.black.withOpacity(0.5),
            strokeWidth: 1,
            zIndex: 1,
            geodesic: true,
          );
          polygons.add(shadowPolygon);
        }
        polygons.add(drawPerimeterPolygon(restaurant));
      }
    }

    onPolygonsUpdated(polygons);
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

  Future<void> loadCircles() async {
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

  Future<void> enable3DView() async {
    if (currentCameraPosition == null) return;
    await mapController?.animateCamera(
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
  Future<void> disable3DView() async {
    if (currentCameraPosition == null) return;
    await mapController?.animateCamera(
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

  Future<void> toggle3DView() async {
    if (currentCameraPosition?.tilt == 0) {
      await enable3DView();
    } else {
      await disable3DView();
    }
  }

  double getMapRotation() {
    return currentCameraPosition?.bearing ?? 0;
  }

  Future<void> setStyle() async {
    if (mapController == null) return;
    //MapStyle style = MapStyleService.mapStyleFromTime(selectedTime!);
    MapStyle style = MapStyle.standard;
    String styleJson = await MapStyleService.getJsonStyle(style);
    mapController!.setMapStyle(styleJson);
    MapStyleService.updateTheme();
  }

  Future<void> initShowAnimation(LatLng restaurantPosition) async {
    if (mapController == null) return;

    // Se mueve la cámara a la posición del restaurante con un zoom de 18.
    CameraPosition newCam =
        CameraPosition(target: restaurantPosition, zoom: 18);
    await mapController!.animateCamera(CameraUpdate.newCameraPosition(newCam));

    // Esperar para asegurar que ha terminado el paso anterior
    await Future.delayed(const Duration(seconds: 2));

    // Se inicia la animación de rotación alrededor del restaurante
    await animateAroundRestaurant(restaurantPosition);
  }

  Future<void> animateAroundRestaurant(LatLng restaurantPosition) async {
    const int totalSteps = 72; // Número de pasos en la animación
    const Duration stepDuration = Duration(
        milliseconds: 150); // Duración entre cada paso de la animación.
    double bearing = 0;

    for (int i = 0; i < totalSteps; i++) {
      bearing = (i * 360 / totalSteps).toDouble();
      print('bearing $bearing');
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: restaurantPosition,
            zoom: 18.0,
            tilt: 45.0,
            bearing: bearing,
          ),
        ),
      );
      await Future.delayed(stepDuration);
    }
  }
}
