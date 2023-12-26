
import 'package:app_final/ApiCalls.dart';
import 'package:app_final/Navigation.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:app_final/AppUser.dart';
import 'package:app_final/ValidationService.dart';
import 'package:flutter/material.dart';
import 'package:app_final/SignUpScreen.dart';
import 'package:app_final/HomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  AppUser? lastUser;
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
    // Autocompleta el inicio de sesión si en la sesión anterior el usuario ha marcado la casilla "Recuérdame".
    _rememberMe = await SaveLoad.loadBool("rememberMe");    
    if (_rememberMe) {
      lastUser = await SaveLoad.loadGeneric<AppUser>("currentUser", AppUser.fromJson);
      if (lastUser != null) {
        setState(() {
          _mailController.text = lastUser!.mail ?? 'mail';
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
              lastUser == null || lastUser!.profileImage == null || lastUser!.profileImage!.isEmpty ?
                const CircleAvatar(
                  child: Icon(Icons.person),
                  radius: 60,
                ) :
                Image.network(
                  lastUser!.profileImage!,
                  height: 200,
                ),
              const SizedBox(height: 40.0),
              TextFormField(
                controller: _mailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => ValidationService.validateMailForSignIn(_mailController.text, newUser),
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
    // Credenciales del usuario.
    String mail = _mailController.text;
    String password = _passwordController.text;

    // Busca un usuario registrado con el correo introducido.
    for (int i = 0; i < AppUser.registeredUsers.length; i++ ) {
      if (AppUser.registeredUsers[i].mail == mail) {
        newUser = AppUser.registeredUsers[i];
      }
    }

    if (_signInFormKey.currentState!.validate()) {
      // Intenta iniciar sesión con Supabase.
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(email: mail, password: password);
      
      if (response.session?.accessToken == null) {
        print('Error al iniciar sesión');
      } else {
        // Si el inicio de sesión es exitoso, se guarda el token de acceso personal del usuario.
        final String? userToken = response.session?.accessToken;
        SaveLoad.saveString("user_token", userToken!);
        ApiCalls.updateUserToken(userToken);

        if (newUser != null) {
          // Se guarda el nuevo usuario en preferncias.
          SaveLoad.saveGeneric<AppUser>("currentUser", newUser!, AppUser.toJson);
        }
        // Guarda el estado del checkBox "Recuérdame".
        SaveLoad.saveBool("rememberMe", _rememberMe);

        // Inicia la navegación.
        Navigation.replaceScreen(context, const HomeScreen());
      }
    }
  }
}
