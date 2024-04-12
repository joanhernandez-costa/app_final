
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/screens/RestaurantDetailScreen.dart';
import 'package:app_final/services/MapService/MapService.dart';
import 'package:app_final/services/MapService/MapStyleService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class CustomMapBuilder extends StatefulWidget {
  final MapService mapService;

  CustomMapBuilder({
    required this.mapService
  });

  @override
  CustomMapBuilderState createState() => CustomMapBuilderState();
}

class CustomMapBuilderState extends State<CustomMapBuilder> {
  Completer<GoogleMapController> controllerCompleter = Completer();
  Set<Marker> currentMarkers = {};
  late String styleJson;

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
      NavigationService.showScreen(RestaurantDetailScreen(restaurant: restaurant));
    };
  }  

  void onMapCreated(GoogleMapController controller) async {
    if (!mounted) return;

    controllerCompleter.complete(controller);
    widget.mapService.setMapController(controller);
    styleJson = await widget.mapService.mapStyle.loadMapStyle(MapStyle.night);
    widget.mapService.setMapStyle(styleJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(40.416869, -3.703470),
          zoom: 11.0
        ),
        zoomControlsEnabled: false,
        markers: currentMarkers,
        onCameraMove: (CameraPosition position) {
          widget.mapService.updateCameraPosition(position);
        },
        onCameraIdle: () {
          widget.mapService.onCameraIdle();
        },
      )
    );  
  }
}