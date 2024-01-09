

import 'package:app_final/screens/ErrorScreen.dart';
import 'package:app_final/services/Navigation.dart';
import 'package:app_final/services/SaveLoad.dart';
import 'package:app_final/services/ValidationService.dart';
import 'package:flutter/material.dart';
import 'package:app_final/screens/SignUpScreen.dart';
import 'package:app_final/screens/HomeScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _rememberMe = false;

  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
              Image.network('https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/public/app_final_bucket/perfil.jpg',
                height: 100,
              ),
              const SizedBox(height: 40.0),
              TextFormField(
                controller: _mailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => ValidationService.validateMailForSignIn(_mailController.text),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => ValidationService.validatePasswordForSignIn(_passwordController.text),
              ),
              const SizedBox(height: 10.0,),
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
                      NavigationService.replaceScreen(context, const SignUpScreen());
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
    // Verifica si el formulario es válido
    if (_signInFormKey.currentState!.validate()) {
      // Obtiene las credenciales del usuario
      String email = _mailController.text;
      String password = _passwordController.text;

      // Intenta iniciar sesión con Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      
      // Comprueba si el inicio de sesión fue exitoso
      if (response.session != null) {
        await SaveLoad.saveBool('rememberMe', _rememberMe);
        // Verifica si el widget todavía está montado antes de navegar
        if (mounted) {
          NavigationService.replaceScreen(context, const HomeScreen());
        }
      } else {
        // Si el inicio de sesión no es exitoso, se muestra la pantalla de error.
        print('Respuesta: ${response.toString()}');
        if (mounted) {
          NavigationService.replaceScreen(context, ErrorScreen());
        }
      }
    }
  }
}
