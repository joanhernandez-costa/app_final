import 'package:flutter/services.dart';

class MapStyleService {
  String getStylePath(MapStyle style) {
    switch (style) {
      case MapStyle.night:
        return 'assets/map_styles/night_mode.json';
      case MapStyle.aubergine:
        return 'assets/map_styles/aubergine_mode.json';
      case MapStyle.retro:
        return 'assets/map_styles/retro_mode.json';
      default:
        return '';
    }
  }

  Future<String> loadMapStyle(MapStyle style) async {
    return await rootBundle.loadString(getStylePath(style));
  }
}

enum MapStyle {
  night,
  aubergine,
  retro,
  // MAPA DE DÍA, SOLEADO
  // MAPA DE DÍA, NUBLADO
  // MAPA DE NOCHE
}