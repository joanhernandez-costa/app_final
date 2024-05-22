import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class WeatherData {
  final DateTime timestamp;
  final LatLng location;
  final String weatherDescription;
  final double temperature;
  final double feelsLike;
  final int pressure;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final DateTime sunrise;
  final DateTime sunset;
  final String weatherIconId;

  static List<WeatherData>? weatherForecasts;

  WeatherData({
    required this.timestamp,
    required this.location,
    required this.weatherDescription,
    required this.temperature,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.sunrise,
    required this.sunset,
    required this.weatherIconId,
  });

  static void initializeTimeZone() {
    tz.initializeTimeZones();
  }

  static WeatherData fromJson(Map<String, dynamic> json, LatLng location) {
    var madrid = tz.getLocation('Europe/Madrid');

    try {
      var weatherInfo = json['weather'][0];

      DateTime localSunrise = tz.TZDateTime.fromMillisecondsSinceEpoch(
          madrid, json['sunrise'] * 1000);
      DateTime localSunset = tz.TZDateTime.fromMillisecondsSinceEpoch(
          madrid, json['sunset'] * 1000);

      return WeatherData(
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
        location: location,
        weatherDescription: weatherInfo['description'],
        temperature: (json['temp']['day'] as num).toDouble(),
        feelsLike: (json['feels_like']['day'] as num).toDouble(),
        pressure: json['pressure'],
        humidity: json['humidity'],
        windSpeed: (json['wind_speed'] as num).toDouble(),
        windDeg: json['wind_deg'],
        sunrise: localSunrise,
        sunset: localSunset,
        weatherIconId: weatherInfo['icon'],
      );
    } catch (e) {
      print('Error al procesar JSON: $e');
      rethrow;
    }
  }

  static List<WeatherData> fromDailyJson(
      List<dynamic> dailyForecasts, LatLng location) {
    try {
      return dailyForecasts.map<WeatherData>((forecastJson) {
        Map<String, dynamic> forecastMap = forecastJson as Map<String, dynamic>;
        return WeatherData.fromJson(forecastMap, location);
      }).toList();
    } catch (e) {
      print('Error al procesar lista en fromDailyJson: $e');
      rethrow;
    }
  }

  String getIconUrl() {
    return 'https://openweathermap.org/img/wn/$weatherIconId.png';
  }
}
