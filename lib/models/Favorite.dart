import 'package:app_final/models/RestaurantData.dart';

class Favorite {
  final String favorite_id;
  final String favorite_restaurant_id;
  final String favorite_user_id;

  Favorite({
    required this.favorite_id,
    required this.favorite_restaurant_id,
    required this.favorite_user_id,
  });

  static List<RestaurantData> favoriteRestaurants = [];

  static Map<String, dynamic> toJson(Favorite favorites) {
    return {
      'favorite_id': favorites.favorite_id,
      'favorite_restaurant_id': favorites.favorite_restaurant_id,
      'favorite_user_id': favorites.favorite_user_id,
    };
  }

  static Favorite fromJson(Map<String, dynamic> json) {
    return Favorite(
      favorite_id: json['favorite_id'] as String,
      favorite_restaurant_id: json['favorite_restaurant_id'] as String,
      favorite_user_id: json['favorite_user_id'] as String,
    );
  }
}
