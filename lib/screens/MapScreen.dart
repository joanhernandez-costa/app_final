import 'dart:async';
import 'dart:math';
import 'package:app_final/models/WeatherData.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/MapService/MapService.dart';
import 'package:app_final/widgets/CustomMapBuilder.dart';
import 'package:app_final/widgets/CustomSearchWidget.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class MapScreen extends StatefulWidget {
  final MapService mapService;

  MapScreen({
    required this.mapService,
  });

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  bool is3DView = false;
  List<WeatherData>? forecasts;

  double? userHeadingDirection = 0;
  double mapRotation = 0.0;

  StreamSubscription<CompassEvent>? compassSubscription;

  @override
  void initState() {
    super.initState();
    compassSubscription = FlutterCompass.events!.listen((CompassEvent event) {
      if (!mounted) return;
      setState(() {
        userHeadingDirection = event.heading;
      });
      updateCompassDirection();
    });
    forecasts = WeatherData.weatherForecasts;
  }

  @override
  void dispose() {
    compassSubscription?.cancel();
    super.dispose();
  }

  void updateCompassDirection() {
    if (widget.mapService.mapController == null) return;

    double newMapRotation = widget.mapService.getMapRotation();
    if (mapRotation != newMapRotation) {
      setState(() {
        mapRotation = newMapRotation;
      });
    }
  }

  void resetMapRotation() {
    if (widget.mapService.mapController == null) return;

    widget.mapService.mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: widget.mapService.currentCameraPosition!.target,
          zoom: widget.mapService.currentCameraPosition!.zoom,
          bearing: 0,
          tilt: widget.mapService.currentCameraPosition!.tilt,
        ),
      ),
    );

    setState(() {
      mapRotation = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcular ángulo combinando dirección del usuario y la rotación del mapa.
    double combinedAngle =
        ((userHeadingDirection ?? 0) - mapRotation - 45) % 360;
    double angleInRadians = combinedAngle * (pi / 180);

    return Scaffold(
      body: Stack(
        children: [
          CustomMapBuilder(mapService: widget.mapService),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: RestaurantSearchWidget(
              onSelected: (restaurant) {
                widget.mapService.move(LatLng(
                    restaurant.data.latitude, restaurant.data.longitude));
              },
            ),
          ),
          if (forecasts != null && false)
            Positioned(
              top: MediaQuery.of(context).padding.top + 90,
              left: 10,
              right: 10,
              child: Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecasts!.length,
                  itemBuilder: (context, index) {
                    final forecast = forecasts![index];
                    return Container(
                      width: 150,
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.network(forecast.getIconUrl(), width: 50),
                            Text(
                              DateFormat('EEE, d MMM', 'es_ES')
                                  .format(forecast.timestamp),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${forecast.temperature}°C'),
                            Text(forecast.weatherDescription),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          Positioned(
            right: 10,
            bottom: 90,
            child: GestureDetector(
              onTap: resetMapRotation,
              child: Transform.rotate(
                angle: angleInRadians,
                child: const Icon(
                  Icons.explore,
                  color: ColorService.secondary,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: ColorService.secondary,
              onPressed: () {
                setState(() {
                  is3DView = !is3DView;
                  widget.mapService.toggle3DView();
                });
              },
              child: Text(
                is3DView ? '3D' : '2D',
                style: const TextStyle(
                  decorationThickness: 20.0,
                  color: ColorService.textOnPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
