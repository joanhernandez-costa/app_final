import 'dart:math';
import 'package:apsl_sun_calc/apsl_sun_calc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SunPositionService {
  /// Devuelve el azimut solar en grados para una latitud, longitud y fecha/hora local dados.
  double calculateSolarAzimuth(LatLng position, DateTime localTime) {
    var solarData = SunCalc.getSunPosition(
        localTime.toUtc(), position.latitude, position.longitude);
    double azimuthInDegrees = solarData['azimuth']! * (180 / pi);
    return (azimuthInDegrees + 360) % 360;
  }

  /// Devuelve la elevación solar en grados para una latitud, longitud y fecha/hora local dados.
  double getSunElevation(LatLng position, DateTime localTime) {
    var solarData = SunCalc.getSunPosition(
        localTime.toUtc(), position.latitude, position.longitude);
    double altitudeInDegrees = solarData['altitude']! * (180 / pi);
    return altitudeInDegrees;
  }

  Future<DateTime> getSunrise(LatLng position) async {
    var times = await SunCalc.getTimes(
        DateTime.now(), position.latitude, position.longitude);
    return times['sunrise']!;
  }

  Future<DateTime> getSunset(LatLng position) async {
    var times = await SunCalc.getTimes(
        DateTime.now(), position.latitude, position.longitude);
    return times['sunset']!;
  }
}

/*
import 'dart:math';
import 'package:app_final/services/MapService/Utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SunPositionService {
  
  /// Calcula el azimut solar y la elevación solar dado una latitud, longitud y fecha/hora local.
  /// - `latitude`: Latitud del observador en grados.
  /// - `longitude`: Longitud del observador en grados.
  /// - `localTime`: Fecha y hora local del observador.
  /// 
  /// Conceptos importantes:
  /// Azimut solar: ángulo entre el norte geográfico y el punto en el que el sol está ubicado en el cielo, medido en el plano horizontal.
  /// Declinación solar: ángulo que forma la línea Sol-Tierra y el plano del ecuador celeste.
  /// Tiempo decimal: divide al día en 10 horas decimales, cada hora decimal en 100 minutos decimales y cada minuto decimal en 100 segundos decimales.
  /// Ecuación de tiempo: La diferencia entre el tiempo solar verdadero y el tiempo solar medio, debido a la órbita elíptica de la Tierra y su inclinación axial.
  
  /// Devuelve el ángulo de incidencia con el que los rayos de sol chocan contra los objetos.
  /// 
  /// Fórmula completa: ángulo de incidencia = sin(e) * sin(b) + cos(e) * cos(b) * cos(a - o)
  /// e = elevación solar
  /// a = azimuth solar
  /// b = inclinación de la superfície respecto al plano horizontal
  /// o = orientación de la superfície respecto al norte geográfico
  double getIncidenceAngle(LatLng position, DateTime localTime) {
    double sunElevation = getSunElevation(position, localTime);

    // Para una superficie horizontal, el ángulo de incidencia es simplemente 90° - elevación solar
    return 90 - sunElevation;
  }

  /// Devuelve el azimut solar en grados.
  double calculateSolarAzimuth(LatLng position, DateTime localTime) {
    // Convierte la latitud, la declinación y ángulo horario en radianes.
    double radLatitude = Utils.degreesToRadians(position.latitude);
    double radDeclination = Utils.degreesToRadians(calculateSolarDeclination(localTime));
    double radHourAngle = Utils.degreesToRadians(calculateHourAngle(localTime, position));

    // Cálculo del coseno del azimut.
    double cosAzimuth = (sin(radDeclination) * sin(radLatitude) + cos(radDeclination) * cos(radLatitude) * cos(radHourAngle)) /
                        cos(Utils.degreesToRadians(getSunElevation(position, localTime)));

    // Verificación de límites para el cosAzimuth
    cosAzimuth = min(max(cosAzimuth, -1.0), 1.0);

    // Cálculo del azimut en radianes y su conversión a grados
    double azimuth = acos(cosAzimuth);
    azimuth = Utils.radiansToDegrees(azimuth);

    // Ajustar el azimut según la hora del día.
    if (Utils.radiansToDegrees(radHourAngle) < 0) {
      azimuth = 180 - azimuth;
    } else {azimuth = 540 - azimuth;} // Ajuste para asegurar el rango correcto en la tarde
    azimuth = azimuth % 360; // Normalizar el azimut a un rango de 0-360 grados

    return azimuth;
  }

  // Devuelve la declinación solar en grados.
  // Se sigue la fórmula: declination = 23.45° * sin(360/365 * (d - 81))
  // d = número de días desde el 1 de enero.
  double calculateSolarDeclination(DateTime localTime) {
    int dayOfYear = getDayOfYear(localTime);
    return 23.45 * sin(Utils.degreesToRadians((360/365) * (dayOfYear - 81)));
  }

  /// Retorna la ecuación de tiempo en minutos.
  double getEquationOfTime(DateTime localTime) {
    int dayOfYear = getDayOfYear(localTime);
    // Se calcula como una proporción del año transcurrido, expresada en grados.
    double alpha = Utils.degreesToRadians((360 / 365) * (dayOfYear - 81));

    // Calcular y retornar la elevación del sol.
    return 9.87 * sin(2 * alpha) - 7.53 * cos(alpha) - 1.5 * sin(alpha);
  }

  // Devuelve la elevación del sol en grados, que es el ángulo entre el sol y el horizonte.
  double getSunElevation(LatLng position, DateTime localTime) {
    double declination = calculateSolarDeclination(localTime);
    double radLatitude = Utils.degreesToRadians(position.latitude);
    double radDeclination = Utils.degreesToRadians(declination);
    double radHourAngle = Utils.degreesToRadians(calculateHourAngle(localTime, position));

    // Cálculo del ángulo de elevación del sol usando la fórmula del ángulo de elevación solar.
    double elevation = asin(sin(radLatitude) * sin(radDeclination) + 
                            cos(radLatitude) * cos(radDeclination) * cos(radHourAngle));

    return Utils.radiansToDegrees(elevation);
  }

  double calculateHourAngle(DateTime localTime, LatLng position) {
    double equationOfTime = getEquationOfTime(localTime);
    int localStandardTimeMeridian = 15 * localTime.timeZoneOffset.inHours;
    double timeCorrectionFactor = 4 * (position.longitude - localStandardTimeMeridian) + equationOfTime;

    Duration correction = Duration(minutes: timeCorrectionFactor.round());
    DateTime correctedLocalTime = localTime.add(correction);
    double decimalHour = correctedLocalTime.hour + correctedLocalTime.minute / 60.0 + correctedLocalTime.second / 3600.0;

    // El ángulo horario es 0 cuando el sol está en el meridiano local. Se ajusta por 15 grados por cada hora antes o después del mediodía.
    double hourAngle = (decimalHour - 12) * 15;

    return hourAngle;
  }

  // Devuelve el día del año como un entero.
  int getDayOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final difference = date.difference(firstDayOfYear).inDays;
    return difference + 1; // Se suma 1 porque inDays cuenta desde 0
  }

  static bool isRestaurantInSunLight(LatLng position, DateTime localTime) {
    return true;
  }
}
*/