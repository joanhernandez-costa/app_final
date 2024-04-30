import 'package:app_final/models/WeatherData.dart';
import 'package:app_final/services/ThemeService.dart';
import 'package:flutter/services.dart';

enum MapStyle {
  night,
  aubergine,
  retro,
  standard,
  // MAPA DE DÍA, SOLEADO
  // MAPA DE DÍA, NUBLADO
  // MAPA DE NOCHE
}

class MapStyleService {
  static final Map<MapStyle, String> mapStyles = {
    MapStyle.night: 'nightTheme',
    MapStyle.aubergine: 'aubergineTheme',
    MapStyle.retro: 'retroTheme',
    MapStyle.standard: 'default',
  };

  static MapStyle currentMapStyle = MapStyle.standard;

  static String getStylePath(MapStyle style) {
    switch (style) {
      case MapStyle.night:
        return 'assets/map_styles/night_mode.json';
      case MapStyle.aubergine:
        return 'assets/map_styles/aubergine_mode.json';
      case MapStyle.retro:
        return 'assets/map_styles/retro_mode.json';
      case MapStyle.standard:
        return 'assets/map_styles/standard_mode.json';
      default:
        return '';
    }
  }

  static void setMapStyleFromWeather(WeatherData weather) {
    switch (weather.weatherIconId) {
      case '01d': // Cielo claro, día
        currentMapStyle = MapStyle.standard;
      case '01n': // Cielo claro, noche
        currentMapStyle = MapStyle.night;
      case '02d': // Algunas nubes, día
        currentMapStyle = MapStyle.standard;
      case '02n': // Algunas nubes, noche
        currentMapStyle = MapStyle.night;
      case '03d': // Nublado, día
        currentMapStyle = MapStyle.retro;
      case '03n': // Nublado, noche
        currentMapStyle = MapStyle.aubergine;
      case '04d': // Nubosidad, día
        currentMapStyle = MapStyle.retro;
      case '04n': // Nubosidad, noche
        currentMapStyle = MapStyle.aubergine;
      case '09d': // Lluvia ligera, día
        currentMapStyle = MapStyle.retro;
      case '09n': // Lluvia ligera, noche
        currentMapStyle = MapStyle.night;
      case '10d': // Lluvia, día
        currentMapStyle = MapStyle.standard;
      case '10n': // Lluvia, noche
        currentMapStyle = MapStyle.night;
      case '11d': // Tormenta, día
        currentMapStyle = MapStyle.standard;
      case '11n': // Tormenta, noche
        currentMapStyle = MapStyle.night;
      case '13d': // Nieve, día
        currentMapStyle = MapStyle.retro;
      case '13n': // Nieve, noche
        currentMapStyle = MapStyle.aubergine;
      case '50d': // Niebla, día
        currentMapStyle = MapStyle.retro;
      case '50n': // Niebla, noche
        currentMapStyle = MapStyle.aubergine;

      default:
        currentMapStyle = MapStyle.standard;
    }
  }

  static void mapStyleFromTime(DateTime selectedTime) {
    final currentHour = selectedTime.hour;

    switch (currentHour) {}
    updateTheme();
  }

  static Future<String> getJsonStyle(MapStyle newMapStyle) async {
    return await rootBundle.loadString(getStylePath(newMapStyle));
  }

  static void updateTheme() {
    String themeKey = mapStyles[currentMapStyle] ?? 'default';
    ThemeService.switchTheme(themeKey);
  }
}
