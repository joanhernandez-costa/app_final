import 'package:app_final/services/ThemeService.dart';
import 'package:app_final/services/UserService.dart';
import 'package:app_final/widgets/CustomButtons.dart';
import 'package:flutter/material.dart';
import 'package:app_final/models/AppUser.dart';
import 'package:app_final/services/MediaService.dart';
import 'package:app_final/services/ValidationService.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var currentUser = UserService.currentUser.value;

    _userNameController.text = currentUser?.userName ?? '';
    _mailController.text = currentUser?.mail ?? '';
  }

  // Función para formatear y mostrar fechas
  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    var userData = UserService
        .currentUser.value?.userData; // Obtener UserData del currentUser
    var userInfo = userData != null
        ? {
            'Uso Diario Promedio':
                '${userData.averageDailyUsage.inMinutes.toString()} minutos',
            'Último Inicio de Sesión': formatDate(userData.lastLogin),
            'Número de Sesiones': userData.numberOfSessions.toString(),
            'Fecha de Creación': formatDate(userData.createdAt),
            'Duración Promedio de Sesiones':
                '${userData.averageSessionDuration.inMinutes.toString()} minutos',
          }
        : {};

    return Scaffold(
      backgroundColor: ThemeService.currentTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                      UserService.currentUser.value?.profileImageUrl ??
                          'https://your-placeholder-image-url.com'),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: pickAndUploadImage,
                  tooltip: 'Editar imagen de perfil',
                ),
                _buildEditableField('Nombre de Usuario', _userNameController),
                _buildEditableField('Correo Electrónico', _mailController),
                _buildEditableField('Contraseña', _passwordController,
                    obscureText: true),
                const SizedBox(height: 20),
                SecondaryButton()
                    .createButton(const Text('Actualizar'), _updateProfile),
                const SizedBox(height: 20),
                const Text(
                  "Estadísticas de uso:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userInfo.length,
                  itemBuilder: (context, index) {
                    String key = userInfo.keys.elementAt(index);
                    return ListTile(
                      title: Text(key),
                      subtitle: Text(userInfo[key]!),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: ThemeService.currentTheme.textOnPrimary,
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscureText,
      ),
    );
  }

  void pickAndUploadImage() async {
    var url = await MediaService.pickImage();
    setState(() {
      UserService.currentUser.value!.profileImageUrl = url;
    });
  }

  void _updateProfile() {
    // Variables para almacenar posibles errores de validación
    String? userNameError = _userNameController.text.isNotEmpty
        ? ValidationService.validateUserName(_userNameController.text)
        : null;
    String? mailError = _mailController.text.isNotEmpty
        ? ValidationService.validateMailForSignUp(_mailController.text)
        : null;
    String? passwordError = _passwordController.text.isNotEmpty
        ? ValidationService.validatePasswordForSignUp(
            _passwordController.text, _passwordController.text)
        : null;

    // Comprobar si hay errores antes de proceder
    if (userNameError != null || mailError != null || passwordError != null) {
      print('Error: $userNameError, $mailError, $passwordError');
      return;
    }

    // Obtener usuario actual
    var currentUser = UserService.currentUser.value;

    // Actualizar solo los campos que el usuario ha cambiado
    String updatedUserName = _userNameController.text.isNotEmpty
        ? _userNameController.text
        : currentUser?.userName ?? '';
    String updatedMail = _mailController.text.isNotEmpty
        ? _mailController.text
        : currentUser?.mail ?? '';
    String updatedPassword = _passwordController.text.isNotEmpty
        ? _passwordController.text
        : currentUser?.password ?? '';

    // Crear una nueva instancia de AppUser con los datos actualizados
    AppUser updatedUser = AppUser(
      userName: updatedUserName,
      mail: updatedMail,
      password: updatedPassword,
      id: currentUser?.id,
      profileImageUrl: currentUser?.profileImageUrl,
    );

    // Llamar a UserService para actualizar el usuario
    UserService.updateCurrentUser(updatedUser).then((_) {
      // Mostrar mensaje de éxito
      final snackBar = SnackBar(
          content:
              Text('Perfil de ${updatedUser.userName} actualizado con éxito'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }).catchError((error) {
      // Mostrar mensaje de error
      final snackBar =
          SnackBar(content: Text('Error al actualizar el perfil: $error'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }
}
