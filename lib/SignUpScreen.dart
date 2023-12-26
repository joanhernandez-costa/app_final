import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:app_final/ApiCalls.dart';
import 'package:app_final/HomeScreen.dart';
import 'package:app_final/Navigation.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:app_final/ValidationService.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:app_final/AppUser.dart' as app_user;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  String? _profileImageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      String? url = await ApiCalls.uploadFileToStorage(File(pickedFile.path), basename(pickedFile.path));
      setState(() {
        _profileImageUrl = url;
      });
    }
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
                        _profileImageUrl == null
                            ? 'https://us.123rf.com/450wm/nuwaba/nuwaba1707/nuwaba170700076/81763793-persona-usuario-icono-de-ilustraci%C3%B3n-de-amigo-vectror-aislado-sobre-fondo-gris.jpg'
                            : _profileImageUrl!,
                        height: 200,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 10), // Personaliza estos márgenes como desees
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const Icon(
                            Icons.edit, 
                            size: 24, 
                            color: Colors.white, 
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
                    obscureText: _obscureText, // Usa la variable para controlar la visibilidad
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _repeatPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Repite la contraseña',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Cambia el ícono basado en la visibilidad de la contraseña
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
    print(charsList.join(''));
    return charsList.join('');
  }

  void _submitForm(BuildContext context) async {
    if (_signUpFormKey.currentState!.validate()) { 
      
      String newUserName = _userNameController.text;
      String newMail = _mailController.text;
      String newPassword = _passwordController.text;
      String hashedPass = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      app_user.AppUser newUser = app_user.AppUser.full(
        userName: newUserName, 
        mail: newMail, 
        password: hashedPass, 
        profileImage: _profileImageUrl,
      );

      final response = await Supabase.instance.client.auth.signUp(email: newMail, password: newPassword);
      final String? userToken = response.session?.accessToken;

      if (userToken != null) {
        SaveLoad.saveString("user_token", userToken);
        ApiCalls.updateUserToken(userToken);
      } 
      
      ApiCalls.postItem(newUser, toJson: app_user.AppUser.toJson);
      SaveLoad.saveGeneric("currentUser", newUser, app_user.AppUser.toJson);
      Navigation.replaceScreen(context, HomeScreen());
    }
  }

}