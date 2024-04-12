
import 'dart:math';
import 'package:app_final/models/UserData.dart';
import 'package:app_final/screens/ErrorScreen.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/MediaService.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/screens/HomeScreen.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/UserService.dart';
import 'package:app_final/services/ValidationService.dart';
import 'package:app_final/widgets/CustomButtons.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:app_final/models/AppUser.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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

  String _profileImageUrl = 'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/Recurso%2090.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL1JlY3Vyc28gOTAucG5nIiwiaWF0IjoxNzA5MDU1NTA0LCJleHAiOjE3NDA1OTE1MDR9.6WZK6dxPkpfkfpsrBrski443OFO1U65WnoPofzCLhvo&t=2024-02-27T17%3A38%3A28.313Z';

  Future<void> _pickImage() async {
    var url = await MediaService.pickImage() ?? _profileImageUrl;
    setState(() {
      _profileImageUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorService.background,
      appBar: AppBar(
        title: const Text(
          "Registro",
          style: TextStyle(color: ColorService.textOnPrimary),
        ),
        backgroundColor: ColorService.secondary,
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
                        height: 200,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const Icon(
                            Icons.edit, 
                            size: 40, 
                            color: Colors.black, 
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40.0),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: ColorService.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _userNameController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: ColorService.textOnPrimary,
                            labelText: 'Nombre de usuario',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => ValidationService.validateUserName(_userNameController.text),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _mailController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: ColorService.textOnPrimary,
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => ValidationService.validateMailForSignUp(_mailController.text),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: ColorService.textOnPrimary,
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
                            filled: true,
                            fillColor: ColorService.textOnPrimary,
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
                            PrimaryButton().createButton(const Text('Registrarse'), () {_submitForm(context);}),
                            SecondaryButton().createButton(const Text('Generar'), () {_generateRandomPassword();})
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

        ApiService.postItem(newUser, toJson: AppUser.toJson);

        UserData newUserData = UserData(
          user_data_id: Uuid().v4(),
          user_id: response.user!.id, 
          averageDailyUsage: Duration.zero, 
          lastLogin: DateTime.now(), 
          numberOfSessions: 1, 
          createdAt: DateTime.now(),
          averageSessionDuration: Duration.zero,
        );
        await ApiService.postItem(newUserData, toJson: UserData.toJson);

        newUser.userData = newUserData;
        UserService.currentUser.value = newUser;

        if (mounted) {
          NavigationService.replaceScreen(const HomeScreen());
        } 
      } else {
        print('Sesión: ${response.session.toString()}, Usuario: ${response.user.toString()}.');
        if (mounted) {
          NavigationService.showScreen(ErrorScreen());
        }
      }
    }
  }
}