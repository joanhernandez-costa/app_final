import 'package:app_final/services/ThemeService.dart';
import 'package:flutter/material.dart';
import 'package:app_final/models/WeatherData.dart';
import 'package:intl/intl.dart';

class WeatherBottomSheet extends StatelessWidget {
  final List<WeatherData> weatherForecasts;

  const WeatherBottomSheet({Key? key, required this.weatherForecasts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildDraggableScrollableSheet(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: buildHandler(context),
        ),
      ],
    );
  }

  Widget buildHandler(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: 40,
          height: 5.0,
          decoration: BoxDecoration(
            color: ThemeService.currentTheme.secondary,
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDraggableScrollableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.5,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: ThemeService.currentTheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHandler(context),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Previsiones meteorológicas",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: weatherForecasts.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.grey),
                  itemBuilder: (BuildContext context, int index) {
                    WeatherData weatherInfo = weatherForecasts[index];
                    String formattedDate = DateFormat('EEEE, d MMM', 'es_ES')
                        .format(weatherInfo.timestamp);

                    return ListTile(
                      leading:
                          Image.network(weatherInfo.getIconUrl(), width: 50),
                      title: Text(formattedDate),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(weatherInfo.weatherDescription),
                          Text('${weatherInfo.temperature}°C'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
