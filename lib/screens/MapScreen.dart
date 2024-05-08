import 'dart:async';
import 'dart:math';
import 'package:app_final/models/WeatherData.dart';
import 'package:app_final/services/MapService/MapService.dart';
import 'package:app_final/services/MapService/MapStyleService.dart';
import 'package:app_final/services/StorageService.dart';
import 'package:app_final/services/ThemeService.dart';
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
  double sliderValue = 0.0;

  StreamSubscription<CompassEvent>? compassSubscription;

  late DateTime sunrise;
  late DateTime sunset;
  late Duration totalDayLength;

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
    //sunrise = DateTime(2024, 4, 30, 7, 14);
    //sunset = DateTime(2024, 4, 31, 7, 14);
    sunrise = forecasts![0].sunrise;
    sunset = forecasts![0].sunset;
    totalDayLength = sunset.difference(sunrise);

    setInitialSliderValue();
    widget.mapService.setSelectedTime(getTimeFromSlider());
    MapStyleService.setMapStyleFromWeather(forecasts![0]);
    widget.mapService.setStyle();
  }

  @override
  void dispose() {
    compassSubscription?.cancel();
    StorageService.saveFloat('sliderValue', sliderValue);
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

  void setInitialSliderValue() async {
    sliderValue = await StorageService.loadFloat('sliderValue') ?? 0.0;
  }

  String getLabelForValue() {
    DateTime time = getTimeFromSlider();
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    // Calcular ángulo combinando dirección del usuario y la rotación del mapa.
    double combinedAngle =
        ((userHeadingDirection ?? 0) - mapRotation - 45) % 360;
    double angleInRadians = combinedAngle * (pi / 180);

    if (forecasts == null || forecasts!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No forecast data available')),
      );
    }

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
          /*
          if (forecasts != null )
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
          */
          Positioned(
            right: 10,
            bottom: 90,
            child: GestureDetector(
              onTap: resetMapRotation,
              child: Transform.rotate(
                angle: angleInRadians,
                child: Icon(
                  Icons.explore,
                  color: ThemeService.currentTheme.secondary,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 20,
            child: FloatingActionButton(
              backgroundColor: ThemeService.currentTheme.secondary,
              onPressed: () {
                setState(() {
                  is3DView = !is3DView;
                  widget.mapService.toggle3DView();
                });
              },
              child: Text(
                is3DView ? '3D' : '2D',
                style: TextStyle(
                  decorationThickness: 20.0,
                  color: ThemeService.currentTheme.textOnPrimary,
                ),
              ),
            ),
          ),
          Positioned(
              right: 60,
              bottom: 20,
              left: 10,
              child: Column(
                children: [
                  Slider(
                    value: sliderValue,
                    onChanged: (value) {
                      setState(() {
                        sliderValue = value;
                        DateTime selectedTime = getTimeFromSlider();
                        widget.mapService.setSelectedTime(selectedTime);
                        widget.mapService.setStyle();
                        if (widget.mapService.currentCameraPosition!.zoom >
                            15) {
                          widget.mapService.loadPolygons();
                        }
                      });
                    },
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: getLabelForValue(),
                    activeColor: ThemeService.currentTheme.primary,
                  )
                ],
              )),
        ],
      ),
    );
  }

  DateTime getTimeFromSlider() {
    DateTime time = sunrise.add(
        Duration(seconds: (totalDayLength.inSeconds * sliderValue).round()));
    return time;
  }
}
