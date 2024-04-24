import 'package:google_maps_flutter/google_maps_flutter.dart';

class WeatherData {
  final DateTime timestamp;
  final LatLng location;
  final String weatherDescription;
  final double temperature;
  final DateTime sunrise;
  final DateTime sunset;
  final String weatherIconId;

  static List<WeatherData>? weatherForecasts;

  WeatherData({
    required this.timestamp,
    required this.location,
    required this.weatherDescription,
    required this.temperature,
    required this.sunrise,
    required this.sunset,
    required this.weatherIconId,
  });

  static WeatherData fromJson(Map<String, dynamic> json, LatLng location) {
    try {
      var weatherInfo = json['weather'][0];

      return WeatherData(
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true),
        location: location,
        weatherDescription: weatherInfo['description'],
        temperature: (json['temp']['day'] as num).toDouble(),
        sunrise: DateTime.fromMillisecondsSinceEpoch(json['sunrise'] * 1000,
            isUtc: true),
        sunset: DateTime.fromMillisecondsSinceEpoch(json['sunset'] * 1000,
            isUtc: true),
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
