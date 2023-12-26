import 'package:app_final/ApiCalls.dart';
import 'package:app_final/HomeScreen.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:app_final/SignUpScreen.dart';
import 'package:app_final/AppUser.dart';
import 'package:app_final/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool? alreadySignedIn = false;
  String? userToken = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: initializeSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (alreadySignedIn! && userToken != null) {
              return const HomeScreen(); // Ir directamente a HomeScreen si se cumple la condición
            }
            return const SignInScreen();
          } else {
            return const LoadingScreen();
          }
        },
      ),
      routes: {
        '/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),     
        '/loading': (context) => const LoadingScreen(),
        // Añadir más rutas según las pantallas
      },
    );
  }

  Future<void> initializeSettings() async {
    await dotenv.load(fileName: 'supabase_initialize.env');
    Supabase.initialize(anonKey: dotenv.env['SUPABASE_KEY']!,
                          url: dotenv.env['SUPABASE_URL']!);

    AppUser.registeredUsers.clear();
    AppUser.registeredUsers = await ApiCalls.getAllItems<AppUser>(fromJson: AppUser.fromJson);

    alreadySignedIn = true ? false : await SaveLoad.loadBool("rememberMe");
    userToken = await SaveLoad.loadString("user_token");
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

