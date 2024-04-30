import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/services/ThemeService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class RestaurantSearchWidget extends StatefulWidget {
  final void Function(RestaurantData) onSelected;

  const RestaurantSearchWidget({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<RestaurantSearchWidget> createState() => RestaurantSearchWidgetState();
}

class RestaurantSearchWidgetState extends State<RestaurantSearchWidget> {
  final TextEditingController typeAheadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TypeAheadField<RestaurantData>(
          suggestionsCallback: (search) =>
              RestaurantData.allRestaurantsData.where((restaurant) {
            return restaurant
                .getParsedName()
                .toLowerCase()
                .contains(search.toLowerCase());
          }).toList(),
          builder: (context, controller, focusNode) {
            return TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ThemeService.currentTheme.textOnPrimary,
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  labelText: 'Busca establecimientos',
                ));
          },
          itemBuilder: (context, restaurant) {
            return ListTile(
              title: Text(restaurant.getParsedName()),
              subtitle: Text(restaurant.getParsedAdress()),
            );
          },
          onSelected: (RestaurantData restaurant) {
            widget.onSelected(restaurant);
          },
        ));
  }

  @override
  void dispose() {
    typeAheadController.dispose();
    super.dispose();
  }
}
