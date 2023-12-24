import 'package:app_final/ApiCalls.dart';
import 'package:app_final/User.dart' as app_user;
import 'package:app_final/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

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
    await dotenv.load(fileName: 'supabase_initialize.env');
    Supabase.initialize(anonKey: dotenv.env['SUPABASE_KEY']!,
                          url: dotenv.env['SUPABASE_URL']!);

    app_user.AppUser.registeredUsers = await ApiCalls.getAllItems<app_user.AppUser>(fromJson: app_user.AppUser.fromJson);
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

