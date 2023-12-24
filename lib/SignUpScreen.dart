import 'package:app_final/ApiCalls.dart';
import 'package:app_final/HomeScreen.dart';
import 'package:app_final/Navigation.dart';
import 'package:app_final/Time.dart';
import 'package:app_final/User.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();

  User? newUser;

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
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => validatePassword(_passwordController.text, _repeatPasswordController.text), 
                    obscureText: true,
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _repeatPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Repite la contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => validatePassword(_passwordController.text, _repeatPasswordController.text), 
                    obscureText: true,
                  ),
                  const SizedBox(height: 40.0),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) { 
      
      String newUserName = _userNameController.text;
      String newMail = _mailController.text;
      String newPassword = _passwordController.text;
      
      ApiCalls.postItem(User.full(userName: newUserName, mail: newMail, password: newPassword), toJson: User.toJson);
      Navigation.replaceScreen(context, HomeScreen());
    }
  }

  String? validateUserName(String userName) {
    const int minLength = 3;
    const int maxLength = 15;

    // Comprobar si el nombre de usuario se ha registrado anteriormente.
    for (User user in User.registeredUsers) {
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

    const int minLength = 8;
    if (password.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres';
    }

    final RegExp numberRegExp = RegExp(r'\d'); // Expresión regular para detectar números
    if (!numberRegExp.hasMatch(password)) {
      return 'La contraseña debe contener al menos un número';
    }

    return null; // No hay errores
  }

}