import 'package:app_final/ApiCalls.dart';
import 'package:app_final/AppUser.dart';
import 'package:app_final/FavouritesScreen.dart';
import 'package:app_final/MapScreen.dart';
import 'package:app_final/ProfileScreen.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  AppUser? currentUser;
  Widget screenToShow = const MapScreen();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    AppUser? loadedUser = await SaveLoad.loadGeneric("currentUser", AppUser.fromJson);
    setState(() {
      currentUser = loadedUser;
    });
  }

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
            currentUser?.profileImage != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(currentUser!.profileImage!),
                )
              : const CircleAvatar(
                  child: Icon(Icons.person),
                ),
            const SizedBox(width: 10),
            Text(
              currentUser?.userName ?? '',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
      body: currentUser == null
        ? const CircularProgressIndicator()
        : screenToShow,
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
                  changeScreen(Center(child: ProfileScreen(currentUser: currentUser!,)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}