import 'dart:io';
import 'dart:math';

import 'package:app_final/ApiCalls.dart';
import 'package:app_final/HomeScreen.dart';
import 'package:app_final/Navigation.dart';
import 'package:app_final/SaveLoad.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:app_final/User.dart' as app_user;
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

  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: _profileImage == null
                        ? Image.network('https://us.123rf.com/450wm/nuwaba/nuwaba1707/nuwaba170700076/81763793-persona-usuario-icono-de-ilustraci%C3%B3n-de-amigo-vectror-aislado-sobre-fondo-gris.jpg', height: 200,)
                        : Image.file(_profileImage!, height: 100),
                  ),
                  const SizedBox(height: 40.0),
                  TextFormField(
                    controller: _userNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => validateUserName(_userNameController.text),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _mailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => validateEmail(_mailController.text),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Cambia el ícono basado en la visibilidad de la contraseña
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          // Actualiza el estado para mostrar/ocultar la contraseña
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (value) => validatePassword(_passwordController.text, _repeatPasswordController.text),
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
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (value) => validatePassword(_passwordController.text, _repeatPasswordController.text),
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
                        onPressed: _submitForm,
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

  final int minPassLength = 8;
  final int maxPassLength = 16;

  String _generateRandomPassword() {
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

  void _submitForm() async {
    if (_signUpFormKey.currentState!.validate()) { 
      
      String newUserName = _userNameController.text;
      String newMail = _mailController.text;
      String newPassword = _passwordController.text;

      String hashedPass = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      app_user.AppUser newUser = app_user.AppUser.full(userName: newUserName, mail: newMail, password: hashedPass);

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

  String? validateUserName(String userName) {
    const int minLength = 3;
    const int maxLength = 15;

    // Comprobar si el nombre de usuario se ha registrado anteriormente.
    for (app_user.AppUser user in app_user.AppUser.registeredUsers) {
      if (user.userName == userName) {
        return 'Este nombre de usuario ya existe.';
      }
    }

    // Comprobar que no esté vacío
    if (userName.isEmpty) {
      return 'El nombre de usuario no puede estar vacío';
    }

    // Comprobar que no exceda el número de caracteres máximo y que supere el mínimo.
    if (userName.length <= minLength && userName.length >= maxLength) {
      return 'El nombre de usuario debe tener más de $minLength y menos de $maxLength caracteres';
    }

    // Expresión regular para validar caracteres permitidos: letras, números y guiones bajos
    final RegExp regExp = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regExp.hasMatch(userName)) {
      return 'Introduce un nombre de usuario válido';
    }

    // Si se superan todos los requisitos
    return null;
  }

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'El correo electrónico no puede estar vacío';
    }

    final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(email)) {
      return 'Introduce una dirección de correo electrónico válida';
    }

    return null;
  }

  String? validatePassword(String password, String passwordRepeat) {
    if (password.isEmpty || passwordRepeat.isEmpty) {
      return 'La contraseña no puede estar vacía';
    }

    if (password != passwordRepeat) {
      return 'Las contraseñas no coinciden';
    }

    if (password.length < minPassLength) {
      return 'La contraseña debe tener al menos $minPassLength caracteres';
    }

    final RegExp numberRegExp = RegExp(r'\d'); // Expresión regular para detectar números
    if (!numberRegExp.hasMatch(password)) {
      return 'La contraseña debe contener al menos un número';
    }

    return null; // No hay errores
  }

}