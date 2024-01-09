
import 'package:app_final/models/AppUser.dart';
import 'package:app_final/screens/FavouritesScreen.dart';
import 'package:app_final/screens/MapScreen.dart';
import 'package:app_final/screens/ProfileScreen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  AppUser? currentUser = AppUser.currentUser.value;
  Widget screenToShow = const MapScreen();

  void changeScreen(Widget newScreen) {
    setState(() {
      screenToShow = newScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double iconSize = screenHeight * 0.035;
    double buttonSpacing = screenWidth * 0.01;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            currentUser?.profileImageUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(currentUser!.profileImageUrl!),
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
        backgroundColor: Colors.orange,
      ),
      body: screenToShow,
      bottomNavigationBar: SizedBox(
        height: screenHeight * 0.1,
        child: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.map, size: iconSize),
                onPressed: () {
                  changeScreen(const Center(child: MapScreen()));
                },
              ),
              SizedBox(width: buttonSpacing),
              IconButton(
                icon: Icon(Icons.favorite, size: iconSize),
                onPressed: () {
                  changeScreen(const Center(child: FavouritesScreen()));
                },
              ),
              SizedBox(width: buttonSpacing),
              IconButton(
                icon: Icon(Icons.person, size: iconSize),
                onPressed: () {
                  changeScreen(const Center(child: ProfileScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}