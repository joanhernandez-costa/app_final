import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/MapService/MapStyleService.dart';
import 'package:app_final/services/MapService/ShadowCastService.dart';
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  GoogleMapController? mapController;
  CameraPosition? currentCameraPosition;
  MapStyleService mapStyle = MapStyleService();
  ShadowCastService shadowService = ShadowCastService();

  LatLngBounds? visibleRegion;
  Set<Marker> markers = <Marker>{};
  Set<Polygon> shadows = <Polygon>{};

  Function(Set<Marker>) onMarkersUpdated;
  Function(Set<Polygon>) onPolygonsUpdated;
  dynamic Function(RestaurantData)? onMarkerTapped;

  MapService({required this.onMarkersUpdated, required this.onPolygonsUpdated});

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

  //Crea un polígono para mostrarlo en el mapa
  Future<Polygon> createPolygonInMap(RestaurantData restaurant) async {
    DateTime localTime = DateTime.now();
    List<LatLng> shadowPerimeter =
        await shadowService.projectShadow(restaurant, localTime);
    shadowPerimeter.add(shadowPerimeter.first);

    final String polygonIdVal = 'polygon_${restaurant.data.id}';
    final PolygonId polygonId = PolygonId(polygonIdVal);

    final Polygon polygon = Polygon(
      polygonId: polygonId,
      points: restaurant.detail.perimeterPoints!,
      fillColor: Colors.red, //ColorService.background,
      strokeColor: ColorService.background,
      strokeWidth: 1,
      zIndex: 1,
      geodesic: true,
    );

    print('Polígono $polygonIdVal añadido');
    return polygon;
  }

/*
  // Función para crear un cuadrado en el mapa
  Polygon createSquareInMap(LatLng centerPosition, double sideLength) {
    double halfSide = sideLength / 2;
    List<LatLng> squarePerimeter = [
      LatLng(centerPosition.latitude + halfSide,
          centerPosition.longitude - halfSide),
      LatLng(centerPosition.latitude + halfSide,
          centerPosition.longitude + halfSide),
      LatLng(centerPosition.latitude - halfSide,
          centerPosition.longitude + halfSide),
      LatLng(centerPosition.latitude - halfSide,
          centerPosition.longitude - halfSide),
    ];

    final String polygonIdVal =
        'square_${centerPosition.latitude}_${centerPosition.longitude}';
    final PolygonId polygonId = PolygonId(polygonIdVal);

    final Polygon square = Polygon(
      polygonId: polygonId,
      points: squarePerimeter,
      fillColor: Colors.green,
      strokeColor: Colors.black,
      strokeWidth: 3,
      zIndex: 2,
      geodesic: true,
    );

    print('Cuadrado $polygonIdVal añadido');
    return square;
  }
*/

  // Agregar un marcador de Punto de Interés (POI)
  void addPOIMarker(RestaurantData restaurant) {
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

    markers.add(marker);
  }

  void onCameraIdle() async {
    // Obtiene el zoom del mapa
    var zoom = await mapController?.getZoomLevel();

    if (zoom! > 15) {
      loadMarkers();
      loadPolygons();
    } else {
      // Eliminar los marcadores si el zoom es demasiado bajo
      removeMarkers();
      removePolygons();
    }
  }

  void loadPolygons() async {
    if (mapController == null) return;

    LatLngBounds visibleRegion = await mapController!.getVisibleRegion();
    Set<Polygon> newPolygons = {};

    for (var restaurant in RestaurantData.allRestaurantsData) {
      LatLng restaurantLocation =
          LatLng(restaurant.data.latitude, restaurant.data.longitude);
      if (visibleRegion.contains(restaurantLocation) &&
          restaurant.detail.perimeterPoints != null) {
        Polygon polygon = await createPolygonInMap(restaurant);
        newPolygons.add(polygon);
      }
    }

    shadows = newPolygons;
    onPolygonsUpdated(shadows);
  }

  // Cargar marcadores basados en la posición central del mapa
  void loadMarkers() async {
    markers.clear();

    LatLngBounds? visibleRegion = await mapController?.getVisibleRegion();
    if (visibleRegion == null) return;

    for (var restaurant in RestaurantData.allRestaurantsData) {
      LatLng restaurantLocation =
          LatLng(restaurant.data.latitude, restaurant.data.longitude);

      if (visibleRegion.contains(restaurantLocation)) {
        addPOIMarker(restaurant);
      }
    }

    onMarkersUpdated(markers);
  }

  void removePolygons() {
    shadows.clear();
    onPolygonsUpdated(shadows);
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

  void setMapStyle(String style) {
    mapController!.setMapStyle(style);
  }
}
