import 'package:app_final/models/AppUser.dart';
import 'package:app_final/screens/FavouritesScreen.dart';
import 'package:app_final/screens/MapScreen.dart';
import 'package:app_final/screens/ProfileScreen.dart';
import 'package:app_final/screens/SettingsScreen.dart';
import 'package:app_final/screens/WeatherScreen.dart';
import 'package:app_final/services/MapService/MapService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/ThemeService.dart';
import 'package:app_final/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  AppUser? currentUser;
  late MapService mapService;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    mapService = MapService(
        onMarkersUpdated: (Set<Marker> markers) {},
        onPolygonsUpdated: (Set<Polygon> shadows) {},
        onCirclesUpdated: (Set<Circle> circles) {});
    currentUser = UserService.currentUser.value;
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget buildScreen() {
    switch (selectedIndex) {
      case 0:
        return MapScreen(mapService: mapService);
      case 1:
        return const FavouritesScreen();
      case 2:
        return const ProfileScreen();
      case 3:
        return WeatherScreen();
      default:
        return MapScreen(mapService: mapService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.currentTheme.background,
      appBar: AppBar(
        backgroundColor: ThemeService.currentTheme.secondary,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            currentUser?.profileImageUrl != null
                ? CircleAvatar(
                    backgroundImage:
                        NetworkImage(currentUser!.profileImageUrl!),
                  )
                : const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
            const SizedBox(width: 10),
            Text(
              currentUser?.userName ?? 'userName',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: ThemeService.currentTheme.textOnPrimary,
            onPressed: () {
              NavigationService.showScreen(SettingsScreen());
            },
          ),
        ],
      ),
      body: buildScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Tiempo',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: ThemeService.currentTheme.primary,
        unselectedItemColor: ThemeService.currentTheme.secondary,
        showUnselectedLabels: true,
        onTap: onItemTapped,
      ),
    );
  }
}
