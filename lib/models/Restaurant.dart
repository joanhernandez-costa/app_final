// ignore_for_file: non_constant_identifier_names

class Restaurant {
  final String id;
  final String local_name;
  final double latitude;
  final double longitude;
  final String street_type;
  final String adress;
  final String door_number;
  final String? telephone;
  final String? web_page;
  final double averageRating;

  Restaurant({
    required this.id,
    required this.local_name,
    required this.latitude,
    required this.longitude,
    required this.street_type,
    required this.adress,
    required this.door_number,
    this.telephone,
    this.web_page,
    required this.averageRating,
  });

  static Map<String, dynamic> toJson(Restaurant restaurant) {
    return {
      'restaurant_id': restaurant.id,
      'local_name': restaurant.local_name,
      'latitude': restaurant.latitude,
      'longitude': restaurant.longitude,
      'street_type': restaurant.street_type,
      'adress': restaurant.adress,
      'door_number': restaurant.door_number,
      'telephone': restaurant.telephone,
      'web_page': restaurant.web_page,
    };
  }

  static Restaurant fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['restaurant_id'] as String,
      local_name: json['local_name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      street_type: json['street_type'] as String? ?? 'Desconocido',
      adress: json['adress'] as String? ?? 'Desconocido',
      door_number: json['door_number'] as String? ?? 'Desconocido',
      telephone: json['telephone'] as String? ?? 'Desconocido',
      web_page: json['web_page'] as String? ?? 'Desconocido',
      averageRating: json['average_rating'] as double,
    );
  }
}
