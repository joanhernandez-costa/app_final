import 'package:app_final/models/WeatherData.dart';
import 'package:app_final/services/ThemeService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatelessWidget {
  WeatherScreen({super.key});

  final List<WeatherData>? forecasts = WeatherData.weatherForecasts;

  @override
  Widget build(BuildContext context) {
    if (forecasts == null || forecasts!.isEmpty) {
      return const Scaffold(
        body: Center(
            child: Text('No hay información meteorológica en estos momentos.')),
      );
    }

    return buildWeatherContent();
  }

  Widget buildWeatherContent() {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: forecasts!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        WeatherData weather = forecasts![index];
        String formattedDate = capitalizeFirstLetter(
            DateFormat('EEEE, d MMMM', 'es_ES').format(weather.timestamp));

        return Card(
          color: ThemeService.currentTheme.surface,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(weather.getIconUrl(), width: 50),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedDate[0].toUpperCase() +
                              formattedDate.substring(
                                  1, formattedDate.length - 1),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeService.currentTheme.textOnSurface),
                        ),
                        Text(
                          capitalizeFirstLetter(weather.weatherDescription),
                          style: TextStyle(
                            fontSize: 16,
                            color: ThemeService.currentTheme.textOnSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Temperatura: ${weather.temperature}°C',
                  style: TextStyle(
                      fontSize: 16,
                      color: ThemeService.currentTheme.textOnSurface),
                ),
                Text(
                  'Sensación térmica: ${weather.feelsLike}°C',
                  style: TextStyle(
                      fontSize: 16,
                      color: ThemeService.currentTheme.textOnSurface),
                ),
                Text(
                  'Humedad: ${weather.humidity}%',
                  style: TextStyle(
                      fontSize: 16,
                      color: ThemeService.currentTheme.textOnSurface),
                ),
                Text(
                  'Presión: ${weather.pressure} hPa',
                  style: TextStyle(
                      fontSize: 16,
                      color: ThemeService.currentTheme.textOnSurface),
                ),
                Text(
                  'Viento: ${weather.windSpeed} m/s en dirección ${weather.windDeg}°',
                  style: TextStyle(
                      fontSize: 16,
                      color: ThemeService.currentTheme.textOnSurface),
                ),
                Text(
                  'Amanecer: ${DateFormat('HH:mm').format(weather.sunrise)}',
                  style: TextStyle(
                      fontSize: 16,
                      color: ThemeService.currentTheme.textOnSurface),
                ),
                Text(
                  'Atardecer: ${DateFormat('HH:mm').format(weather.sunset)}',
                  style: TextStyle(
                      fontSize: 16,
                      color: ThemeService.currentTheme.textOnSurface),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
