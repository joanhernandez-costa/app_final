import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //currentSettings = await SaveLoad.loadSettings();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: initializeSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Carga completada, navegar a la pantalla principal
            return HomeScreen(); // Reemplaza HomeScreen con tu pantalla principal
          } else {
            // Mientras se carga, muestra la pantalla de carga
            return const LoadingScreen();
          }
        },
      ),
    );
  }
}


class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
