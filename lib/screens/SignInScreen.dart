

import 'package:app_final/screens/ErrorScreen.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/ValidationService.dart';
import 'package:app_final/widgets/CustomButtons.dart';
import 'package:flutter/material.dart';
import 'package:app_final/screens/SignUpScreen.dart';
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
      backgroundColor: ColorService.background,
      appBar: AppBar(
        title: const Text("Inicio de sesión", style: TextStyle(color: ColorService.textOnPrimary)),
        backgroundColor: ColorService.secondary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _signInFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 40,),
                Image.network(
                  'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/logo_recortado.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL2xvZ29fcmVjb3J0YWRvLnBuZyIsImlhdCI6MTcxMTgxNzM4NCwiZXhwIjoxNzQzMzUzMzg0fQ.l2nZWZtggW15CK6qX88ZS7poZvHNdOrecQsVyBOjsx0&t=2024-03-30T16%3A49%3A47.703Z',
                  height: 175,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 40.0),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: ColorService.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Checkbox(
                            activeColor: ColorService.primary,
                            value: _rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          const Text("Recuérdame", style: TextStyle(color: ColorService.textOnPrimary)),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SecondaryButton().createButton(const Text('No estoy registrado'), () {
                              NavigationService.replaceScreen(const SignUpScreen());
                            }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PrimaryButton().createButton(const Text('Iniciar sesión'), () {
                              signIn();
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      if (response.session == null) {
        // Si el inicio de sesión no es exitoso, se muestra la pantalla de error.
        print('Respuesta: ${response.toString()}');
        if (mounted) {
          NavigationService.showScreen(ErrorScreen());
        }
      }
    }
  }
}
