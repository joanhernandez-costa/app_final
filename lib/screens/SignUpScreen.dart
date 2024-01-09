
import 'dart:math';
import 'package:app_final/screens/ErrorScreen.dart';
import 'package:app_final/services/MediaService.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/screens/HomeScreen.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/ValidationService.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:app_final/models/AppUser.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  bool _obscureText = true;

  String _profileImageUrl = 'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/public/app_final_bucket/logo_app.png';

  Future<void> _pickImage() async {
    var url = await MediaService.pickImage() ?? _profileImageUrl;
    setState(() {
      _profileImageUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _signUpFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Image.network(
                        _profileImageUrl,
                        height: 100,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10),
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const Icon(
                            Icons.edit, 
                            size: 24, 
                            color: Colors.black, 
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40.0),
                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => ValidationService.validateUserName(_userNameController.text),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _mailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => ValidationService.validateMailForSignUp(_mailController.text),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => ValidationService.validatePasswordForSignUp(_passwordController.text, _repeatPasswordController.text),
                    obscureText: _obscureText, 
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _repeatPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Repite la contraseña',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (value) => ValidationService.validatePasswordForSignUp(_passwordController.text, _repeatPasswordController.text),
                    obscureText: _obscureText,
                  ),
                  const SizedBox(height: 40.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () => _submitForm(context),
                        child: const Text(
                          "Registrarse",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            String randomPassword = _generateRandomPassword();
                            _passwordController.text = randomPassword;
                            _repeatPasswordController.text = randomPassword;
                          });
                        },
                        child: const Text(
                          "Generar contraseña aleatoria",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _generateRandomPassword() {
    const int minPassLength = 8;
    const int maxPassLength = 20;
    const String letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String digits = '0123456789';
    final Random random = Random();

    int passwordLength = minPassLength + random.nextInt(maxPassLength - minPassLength + 1);

    String pswd = List.generate(passwordLength - 1, (_) => letters[random.nextInt(letters.length)]).join('');
    pswd += digits[random.nextInt(digits.length)];

    // Mezcla los caracteres
    List<String> charsList = pswd.split('');
    charsList.shuffle();
    return charsList.join('');
  }

  void _submitForm(BuildContext context) async {
    if (_signUpFormKey.currentState!.validate()) { 
      
      String newUserName = _userNameController.text;
      String newMail = _mailController.text;
      String newPassword = _passwordController.text;
      String hashedPass = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      final response = await Supabase.instance.client.auth.signUp(email: newMail, password: newPassword);

      if (response.user != null) {
        AppUser newUser = AppUser(
          userName: newUserName, 
          mail: newMail, 
          password: hashedPass, 
          id: response.user!.id,
          profileImageUrl: _profileImageUrl,
        );

        AppUser.currentUser.value = newUser;
        ApiService.postItem(newUser, toJson: AppUser.toJson);
        if (mounted) {
          NavigationService.replaceScreen(context, const HomeScreen());
        } 
      } else {
        print('Sesión: ${response.session.toString()}, Usuario: ${response.user.toString()}.');
        if (mounted) {
          NavigationService.replaceScreen(context, ErrorScreen());
        }
      }
    }
  }
}