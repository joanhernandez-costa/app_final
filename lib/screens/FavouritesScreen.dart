
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/screens/RestaurantDetailScreen.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/UserService.dart';
import 'package:flutter/material.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  FavouritesScreenState createState() => FavouritesScreenState();
}

class FavouritesScreenState extends State<FavouritesScreen> {
  List<RestaurantData> favoriteRestaurants = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteRestaurantsAndRatings();
  }

  void loadFavoriteRestaurantsAndRatings() async {
    List<RestaurantData> restaurants = await ApiService.getFavoriteRestaurants(UserService.currentUser.value!.id!);    

    // Actualiza el estado con los nuevos valores
    setState(() {
      favoriteRestaurants = restaurants;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: favoriteRestaurants.length,
      itemBuilder: (context, index) {

        final restaurant = favoriteRestaurants[index];

        return InkWell(
          onTap: () => {
            NavigationService.showScreen(RestaurantDetailScreen(restaurant: restaurant))
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorService.primary, width: 4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        restaurant.photos_urls[0],
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          restaurant.data.local_name,
                          style: const TextStyle(
                            color: ColorService.textOnPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          restaurant.getParsedAdress(),
                          style: const TextStyle(
                            color: ColorService.textOnPrimary,
                          ),
                        ),
                        Text(
                          "Valoración: ${restaurant.data.averageRating}",
                          style: const TextStyle(
                            color: ColorService.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        );
      }, 
    );
  }
}
