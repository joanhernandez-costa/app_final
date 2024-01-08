
import 'package:app_final/HomeScreen.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:app_final/SignUpScreen.dart';
import 'package:app_final/AppUser.dart';
import 'package:app_final/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(ChangeNotifierProvider.value(
    value: AppUser.currentUser,
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Authentication(),
      routes: {
        '/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        // Añadir más rutas según las pantallas
      },
    );
  }
}

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  AuthenticationState createState() => AuthenticationState();
}

class AuthenticationState extends State<Authentication> {
  bool isLoading = true;
  bool? remembered;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await dotenv.load(fileName: 'supabase_initialize.env');
    await Supabase.initialize(anonKey: dotenv.env['SUPABASE_KEY']!, url: dotenv.env['SUPABASE_URL']!);
    await AppUser.initSupabaseListeners();
    remembered = await SaveLoad.loadBool("rememberMe") ?? false;
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen();
    } 
    if (AppUser.currentUser.value == null || !remembered!) {
      return const SignInScreen();
    }
    return const HomeScreen();
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

