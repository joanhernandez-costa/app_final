import 'package:app_final/ApiCalls.dart';
import 'package:app_final/User.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();

  bool _isUserNameValid = true;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 40.0),
                TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                    border: const OutlineInputBorder(),
                    errorBorder: _isUserNameValid ? null : const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _mailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    border: const OutlineInputBorder(),
                    errorBorder: _isEmailValid ? null : const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    errorBorder: _isPasswordValid ? null : const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _repeatPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Repetir Contraseña',
                    border: const OutlineInputBorder(),
                    errorBorder: _isPasswordValid ? null : const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, 
                  ),
                  onPressed: () {
                    String newUserName = _userNameController.text;
                    String newMail = _mailController.text;
                    String newPassword = _passwordController.text;
                    String repeatPassword = _repeatPasswordController.text;

                    bool isUserNameValid = validateUserName(newUserName);
                    bool isEmailValid = validateEmail(newMail);
                    bool isPasswordValid = validatePassword(newPassword, repeatPassword);

                    if (isUserNameValid && isEmailValid && isPasswordValid) {
                      newUser = User.full(userName: newUserName, mail: newMail, password: newPassword);
                      ApiCalls.postItem<User>(newUser!, toJson: User.toJson);
                    } else {
                      setState(() {
                        _isUserNameValid = isUserNameValid;
                        _isEmailValid = isEmailValid;
                        _isPasswordValid = isPasswordValid;
                      });
                    }
                  },
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
    );
  }

  bool validateUserName(String userName) {
    return false;
  }

  bool validateEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    //return emailRegExp.hasMatch(email);
    return false;
  }

  bool validatePassword(String password, String passwordRepeat) {
    //return password == passwordRepeat;
    return false;
  }
}