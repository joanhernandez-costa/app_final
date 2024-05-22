import 'dart:math';
import 'package:app_final/models/UserData.dart';
import 'package:app_final/screens/ErrorScreen.dart';
import 'package:app_final/services/MediaService.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/screens/HomeScreen.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/ThemeService.dart';
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
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  bool _obscureText = true;

  String _profileImageUrl =
      'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/logo_recortado.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL2xvZ29fcmVjb3J0YWRvLnBuZyIsImlhdCI6MTcxMTg5NDAzMSwiZXhwIjoxNzQzNDMwMDMxfQ.tf5MpdHsO82hWhY_cb6YWIOVfxklA19lIRDVC4esQlY&t=2024-03-31T14%3A07%3A14.453Z';

  Future<void> _pickImage() async {
    var url = await MediaService.pickImage() ?? _profileImageUrl;
    setState(() {
      _profileImageUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.currentTheme.background,
      appBar: AppBar(
        title: Text(
          "Registro",
          style: TextStyle(color: ThemeService.currentTheme.textOnPrimary),
        ),
        backgroundColor: ThemeService.currentTheme.secondary,
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
                      color: ThemeService.currentTheme.surface,
                      borderRadius: BorderRadius.circular(10),
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
                          controller: _userNameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ThemeService.currentTheme.textOnPrimary,
                            labelText: 'Nombre de usuario',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              ValidationService.validateUserName(
                                  _userNameController.text),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _mailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ThemeService.currentTheme.textOnPrimary,
                            labelText: 'Correo electrónico',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              ValidationService.validateMailForSignUp(
                                  _mailController.text),
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ThemeService.currentTheme.textOnPrimary,
                            labelText: 'Contraseña',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              ValidationService.validatePasswordForSignUp(
                                  _passwordController.text,
                                  _repeatPasswordController.text),
                          obscureText: _obscureText,
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _repeatPasswordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: ThemeService.currentTheme.textOnPrimary,
                            labelText: 'Repite la contraseña',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: (value) =>
                              ValidationService.validatePasswordForSignUp(
                                  _passwordController.text,
                                  _repeatPasswordController.text),
                          obscureText: _obscureText,
                        ),
                        const SizedBox(height: 40.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PrimaryButton()
                                .createButton(const Text('Registrarse'), () {
                              _submitForm(context);
                            }),
                            SecondaryButton()
                                .createButton(const Text('Generar'), () {
                              _generateRandomPassword();
                            })
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
    const String letters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String digits = '0123456789';
    final Random random = Random();

    int passwordLength =
        minPassLength + random.nextInt(maxPassLength - minPassLength + 1);

    String pswd = List.generate(
            passwordLength - 1, (_) => letters[random.nextInt(letters.length)])
        .join('');
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

      final response = await Supabase.instance.client.auth
          .signUp(email: newMail, password: newPassword);

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
          user_data_id: const Uuid().v4(),
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
        if (mounted) {
          NavigationService.showScreen(ErrorScreen());
        }
      }
    }
  }
}
