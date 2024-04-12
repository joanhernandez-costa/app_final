
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/MapService/MapStyleService.dart';
import 'package:app_final/services/MapService/ShadowCastService.dart';
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  GoogleMapController? mapController;
  CameraPosition? currentCameraPosition;
  MapStyleService mapStyle = MapStyleService();
  ShadowCastService shadowService = ShadowCastService();

  LatLngBounds? visibleRegion;
  Set<Marker> markers = Set<Marker>();
  Set<Polygon> shadows = Set<Polygon>();
  List<String> currentSymbolIds = [];

  Function(Set<Marker>) onMarkersUpdated;
  dynamic Function(RestaurantData)? onMarkerTapped;

  MapService({required this.onMarkersUpdated});

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
  Future<void> createPolygonInMap(RestaurantData restaurant) async {
    DateTime localTime = DateTime.now();
    List<LatLng> shadowPerimeter = await shadowService.projectShadow(restaurant, localTime);

    final String polygonIdVal = 'polygon_${restaurant.data.id}';
    final PolygonId polygonId = PolygonId(polygonIdVal);

    final Polygon polygon = Polygon(
      polygonId: polygonId,
      points: shadowPerimeter,
      fillColor: ColorService.background.withOpacity(0.5),
      strokeColor: ColorService.background,
      strokeWidth: 1,
    );

    shadows.add(polygon);
  }

  // Agregar un marcador de Punto de Interés (POI)
  void addPOIMarker(RestaurantData restaurant) {
    LatLng restaurantPosition = LatLng(restaurant.data.latitude, restaurant.data.longitude);
    bool isInSunLight = SunPositionService.isRestaurantInSunLight(restaurantPosition, DateTime.now()); 

    final String markerIdVal = 'marker_${restaurant.data.latitude}_${restaurant.data.longitude}';
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: restaurantPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(isInSunLight ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueBlue),
      onTap: () {
        if (onMarkerTapped != null) {
          onMarkerTapped!(restaurant);
        }
      }
    );

    markers.add(marker);
    onMarkersUpdated(markers);
  }

  void onCameraIdle() async {
    // Obtiene el zoom del mapa
    var zoom = await mapController?.getZoomLevel();   

    if (zoom! > 15) { 
      loadMarkers();
    } else {
      // Eliminar los marcadores si el zoom es demasiado bajo
      removeMarkers();
    }
  }

  // Cargar marcadores basados en la posición central del mapa
  void loadMarkers() async {
    markers.clear();

    LatLngBounds? visibleRegion = await mapController?.getVisibleRegion();
    if (visibleRegion == null) return;

    for (var restaurant in RestaurantData.allRestaurantsData) {
      LatLng restaurantLocation = LatLng(restaurant.data.latitude, restaurant.data.longitude);

      if (visibleRegion.contains(restaurantLocation)) {
        addPOIMarker(restaurant);
      }
    }

    onMarkersUpdated(markers);
  }

  void removeMarkers() {
    markers.clear();
    onMarkersUpdated(markers);
  }

  void enable3DView() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
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

  double getMapRotation()  {
    return currentCameraPosition?.bearing ?? 0;
  }

  void setMapStyle(String style) {
    mapController!.setMapStyle(style);
  }

}

