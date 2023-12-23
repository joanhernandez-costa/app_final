import 'package:app_final/HomeScreen.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:app_final/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:app_final/Time.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //currentSettings = await SaveLoad.loadSettings();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: initializeSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_rememberMe) {
              return const HomeScreen();
            } else {
              return const SignInScreen();
            }
          } else {
            return const LoadingScreen();
          }
        },
      ),
    );
  }

  Future<void> initializeSettings() async {
    await Time.waitForSeconds(3);
    _rememberMe = await SaveLoad.loadBool("rememberMe");
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

