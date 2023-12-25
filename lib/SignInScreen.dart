import 'package:app_final/ApiCalls.dart';
import 'package:app_final/Navigation.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:app_final/User.dart';
import 'package:app_final/ValidationService.dart';
import 'package:flutter/material.dart';
import 'package:app_final/SignUpScreen.dart';
import 'package:app_final/HomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late AppUser? currentUser;
  AppUser? newUser;

  bool _rememberMe = false;

  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    _rememberMe = await SaveLoad.loadBool("rememberMe");
    if (_rememberMe) {
      currentUser = await SaveLoad.loadGeneric<AppUser>("currentUser", AppUser.fromJson);

      if (currentUser != null) {
        setState(() {
          _mailController.text = currentUser!.mail ?? 'mail';
          _passwordController.text = currentUser!.password ?? 'password';
        });
      }
    }
  }

  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio de sesión"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _signInFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(
                'https://us.123rf.com/450wm/nuwaba/nuwaba1707/nuwaba170700076/81763793-persona-usuario-icono-de-ilustraci%C3%B3n-de-amigo-vectror-aislado-sobre-fondo-gris.jpg',
                width: 100.0,
                height: 100.0,
              ),
              const SizedBox(height: 40.0),
              TextFormField(
                controller: _mailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => ValidationService.validateMail(_mailController.text),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => ValidationService.validatePasswordForSignIn(_passwordController.text, newUser),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Text("Recuérdame"),
                ],
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigation.replaceScreen(context, const SignUpScreen());
                    },
                    child: const Text(
                      "No estoy registrado",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: signIn,
                    child: const Text(
                      "Iniciar sesión",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signIn() async {
    if (_signInFormKey.currentState!.validate()) {
      String mail = _mailController.text;
      String password = _passwordController.text;

      // Busca un usuario registrado con el correo introducido
      AppUser? newUser = await ApiCalls.getUserWithMail(mail);
    
      // Intenta iniciar sesión con Supabase
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(email: mail, password: password);
      
      if (response.session?.accessToken == null) {
        print('Error al iniciar sesión');
      } else {
        // Si el inicio de sesión es exitoso
        final String? userToken = response.session?.accessToken;

        if (userToken != null) {
          SaveLoad.saveString("user_token", userToken);
          ApiCalls.updateUserToken(userToken);
        }

        if (newUser != null) {
          currentUser = newUser;
          SaveLoad.saveGeneric<AppUser>("currentUser", newUser, AppUser.toJson);
        }

        if (_rememberMe) {        
          // Guarda el usuario actual si se ha marcado "Recuérdame"    
          SaveLoad.saveBool("rememberMe", _rememberMe);
        }

        Navigation.replaceScreen(context, const HomeScreen());
      }
    }
  }
}
