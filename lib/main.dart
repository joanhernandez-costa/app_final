import 'package:app_final/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:app_final/Time.dart';

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
            return const SignInScreen();
          } else {
            return const LoadingScreen();
          }
        },
      ),
    );
  }

  Future<void> initializeSettings() async {
    await Time.waitForSeconds(3);
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

