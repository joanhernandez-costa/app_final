// ignore_for_file: non_constant_identifier_names

import 'package:app_final/models/Restaurant.dart';
import 'package:app_final/models/RestaurantDetail.dart';
import 'package:app_final/models/RestaurantHours.dart';

class RestaurantData {
  Restaurant data;
  RestaurantDetail detail;
  RestaurantHours hours;
  List<String> photos_urls;

  RestaurantData({
    required this.data,
    required this.detail,
    required this.hours,
    required this.photos_urls
  });

  static List<RestaurantData> allRestaurantsData = [];

  static RestaurantData fromJson(Map<String, dynamic> json) {
    // Construye el objeto Restaurant
    Restaurant restaurantData = Restaurant.fromJson(json['restaurant']);
    
    // Construye el objeto RestaurantDetail si está presente
    RestaurantDetail detail = RestaurantDetail.fromJson(json['detail']);
    
    // Construye el objeto RestaurantHours si está presente
    RestaurantHours hours = RestaurantHours.fromJson(json['hours']);
    
    // Construye la lista de strings para fotos
    List<String> photos = json['photos'] != null
        ? (json['photos'] as List<dynamic>).whereType<String>().toList()
        : <String>['https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/logo_recortado.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL2xvZ29fcmVjb3J0YWRvLnBuZyIsImlhdCI6MTcxMDQ0NzQ2MywiZXhwIjoxNzQxOTgzNDYzfQ.bRW_K_YJvI9SKDSSMMBL_Ydgy6WQaanMzbTXAlAcl9k&t=2024-03-14T20%3A17%3A44.147Z'];

    // Retorna una nueva instancia de RestaurantData
    return RestaurantData(
      data: restaurantData,
      detail: detail,
      hours: hours,
      photos_urls: photos,
    );
  }  

  String getParsedAdress() {
    String trimmedStreetType = data.street_type.trim();
    String trimmedAdress = data.adress.trim();

    return '${toTitleCase(trimmedStreetType)} ${toTitleCase(trimmedAdress)}, ${data.door_number}';
  }

  String getParsedName() {
    return toTitleCase(data.local_name);
  }

  String toTitleCase(String str) {
    return str
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }
}