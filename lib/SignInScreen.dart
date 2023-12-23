import 'package:app_final/Navigation.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:app_final/Time.dart';
import 'package:app_final/User.dart';
import 'package:flutter/material.dart';
import 'package:app_final/SignUpScreen.dart';
import 'package:app_final/HomeScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late User currentUser;
  bool _rememberMe = false;
  bool _isButtonRed  = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    _rememberMe = await SaveLoad.loadBool("rememberMe");
    if (_rememberMe) {
      User? user = await SaveLoad.loadGenericObject<User>("currentUser", User.fromJson);

      if (user != null) {
        setState(() {
          _emailController.text = user.mail ?? 'mail';
          _passwordController.text = user.password ?? 'password';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio de sesión"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network(
                  'https://us.123rf.com/450wm/nuwaba/nuwaba1707/nuwaba170700076/81763793-persona-usuario-icono-de-ilustraci%C3%B3n-de-amigo-vectror-aislado-sobre-fondo-gris.jpg',
                  width: 100.0,
                  height: 100.0,
                ),
                const SizedBox(height: 40.0),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
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
                        backgroundColor: _isButtonRed ? Colors.red : Colors.orange,
                      ),
                      onPressed: () async {
                        String mail = _emailController.text;
                        String password = _passwordController.text;

                        bool isValid = validateCredentials(mail, password);

                        if (isValid) {
                          currentUser = User.full(mail: mail, password: password); 
                          if (_rememberMe) {            
                            SaveLoad.saveGenericObject("currentUser", currentUser);
                            SaveLoad.saveBool("rememberMe", _rememberMe);
                          } 

                          Navigation.replaceScreen(context, const HomeScreen());
                        } else {
                          setState(() {
                            _isButtonRed = true;
                          });
                          await Time.waitForSeconds(2);
                          setState(() {
                            _isButtonRed = false;
                          });
                        }
                      },
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
      ),
    );
  }
  
  bool validateCredentials(String mail, String password) {
    return true;
  }
}
