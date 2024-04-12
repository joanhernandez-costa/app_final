import 'package:geolocator/geolocator.dart';

class LocationService {
  
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Comprueba si los servicios de ubicación están habilitados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Los permisos para acceder a la ubicación del usuario no están habilitados. 
      // No se sigue intentando acceder a la ubicación.
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Se solicitan los permisos y el usuario los ha denegado.
        // No se sigue intentando acceder a la ubicación.
        return Future.error('Los permisos de ubicación están denegados');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Los permisos están denegados para siempre.
      // No se pueden solicitar permisos. No se sigue intentando acceder a la ubicación.
      return Future.error(
          'Los permisos de ubicación están permanentemente denegados, no podemos solicitar permisos.');
    } 

    // Cuando tenemos permiso, obtenemos la posición actual del usuario.
    return await Geolocator.getCurrentPosition();
  }
}