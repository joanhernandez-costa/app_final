
import 'package:app_final/models/RestaurantData.dart';
import 'package:app_final/models/WeatherData.dart';
import 'package:app_final/screens/HomeScreen.dart';
import 'package:app_final/screens/ProfileScreen.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/services/LocationService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/StorageService.dart';
import 'package:app_final/screens/SignUpScreen.dart';
import 'package:app_final/models/AppUser.dart';
import 'package:app_final/screens/SignInScreen.dart';
import 'package:app_final/services/UserService.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(ChangeNotifierProvider.value(
    value: UserService.currentUser,
    child: MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      home: const Authentication(),
      routes: {
        '/signIn': (context) => const SignInScreen(),
        '/signUp': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
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

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await dotenv.load(fileName: 'supabase_initialize.env');
    await Supabase.initialize(anonKey: dotenv.env['SUPABASE_KEY']!, url: dotenv.env['SUPABASE_URL']!);

    UserService.registeredUsers = await ApiService.getAllItems<AppUser>(fromJson: AppUser.fromJson);
    RestaurantData.allRestaurantsData = await ApiService.getAllItems(fromJson: RestaurantData.fromJson);
    Position userPosition = await LocationService.getCurrentLocation();
    WeatherData.weatherForecasts = await ApiService.getWeather(DateTime.now(), LatLng(userPosition.latitude, userPosition.longitude));

    await UserService.initSupabaseListeners();

    final session = Supabase.instance.client.auth.currentSession;
    final remembered = await StorageService.loadBool("rememberMe") ?? false;
    UserService.currentUser.value = session != null && remembered
        ? await StorageService.loadGeneric('lastUser', AppUser.fromJson)
        : null;

    if (UserService.currentUser.value != null) {
      // Navegar a HomeScreen si hay una sesión válida.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
      });
    } else {
      // Preparar para mostrar SignInScreen.
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen();
    } else {
      return const SignInScreen();
    }
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network('https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/logo_recortado.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL2xvZ29fcmVjb3J0YWRvLnBuZyIsImlhdCI6MTcxMTg5NDAzMSwiZXhwIjoxNzQzNDMwMDMxfQ.tf5MpdHsO82hWhY_cb6YWIOVfxklA19lIRDVC4esQlY&t=2024-03-31T14%3A07%3A14.453Z'),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        )
      ),
    );
  }
}

