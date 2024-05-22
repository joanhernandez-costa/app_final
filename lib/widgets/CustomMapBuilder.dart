import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/screens/RestaurantDetailScreen.dart';
import 'package:app_final/services/MapService/MapService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class CustomMapBuilder extends StatefulWidget {
  final MapService mapService;

  CustomMapBuilder({required this.mapService});

  @override
  CustomMapBuilderState createState() => CustomMapBuilderState();
}

class CustomMapBuilderState extends State<CustomMapBuilder> {
  Completer<GoogleMapController> controllerCompleter = Completer();
  Set<Marker> currentMarkers = {};
  Set<Polygon> currentPolygons = {};
  Set<Circle> currentCircles = {};

  LatLng initialPosition = const LatLng(40.44909830960289, -3.7121435091200987);

  @override
  void initState() {
    super.initState();

    widget.mapService.onMarkersUpdated = (updatedMarkers) {
      if (!mounted) return;
      setState(() {
        currentMarkers = updatedMarkers;
      });
    };

    widget.mapService.onMarkerTapped = (RestaurantData restaurant) {
      if (!mounted) return;
      NavigationService.showScreen(
          RestaurantDetailScreen(restaurant: restaurant));
    };

    widget.mapService.onPolygonsUpdated = (updatedPolygons) {
      if (!mounted) return;
      setState(() {
        currentPolygons = updatedPolygons;
      });
    };

    widget.mapService.onCirclesUpdated = (updatedCircles) {
      if (!mounted) return;
      setState(() {
        currentCircles = updatedCircles;
      });
    };
  }

  void onMapCreated(GoogleMapController controller) async {
    if (!mounted) return;

    controllerCompleter.complete(controller);
    widget.mapService.setMapController(controller);
  }

  void onMapStyleUpdated() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition:
            CameraPosition(target: initialPosition, zoom: 15),
        zoomControlsEnabled: false,
        markers: currentMarkers,
        polygons: currentPolygons,
        circles: currentCircles,
        onCameraMove: (CameraPosition position) {
          widget.mapService.updateCameraPosition(position);
        },
        onCameraIdle: () {
          widget.mapService.onCameraIdle();
        },
      ),
    );
  }
}
