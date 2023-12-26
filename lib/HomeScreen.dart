import 'package:app_final/ApiCalls.dart';
import 'package:app_final/AppUser.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  AppUser? currentUser;

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

  @override
  Widget build(BuildContext context) {
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
                height: 1,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
      body: currentUser == null
        ? const CircularProgressIndicator()
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.green,
                child: const Center(
                  child: Text('MAPA AQUÍ'),
                ),
              ),
            ),
          ],
        ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                // Navegar a la primera pantalla
              },
            ),
            IconButton(
              icon: Icon(Icons.navigation),
              onPressed: () {
                // Navegar a la segunda pantalla
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                // Navegar a la tercera pantalla
              },
            ),
          ],
        ),
      ),
    );
  }

}