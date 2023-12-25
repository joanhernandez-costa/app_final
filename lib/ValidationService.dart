
import 'package:app_final/User.dart';
import 'package:bcrypt/bcrypt.dart';

class ValidationService {

  static final minPassLength = 8;

  static String? validateUserName(String userName) {
    const int minLength = 3;
    const int maxLength = 15;

    // Comprobar si el nombre de usuario se ha registrado anteriormente.
    for (AppUser user in AppUser.registeredUsers) {
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

  static String? validateMail(String? mail) {
    // Verifica que el correo electrónico no esté vacío.
    if (mail == null || mail.isEmpty) {
      return 'El correo electrónico no puede estar vacío';
    }

    // Expresión regular para verificar formato del correo: "aaaaaa@bbbb.ccc"
    final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(mail)) {
      return 'Introduce una dirección de correo electrónico válida';
    }

    // No hay errores
    return null;
  }

  static String? validatePasswordForSignIn(String? password, AppUser? possibleUser) {
    // Verifica que la contraseña no esté vacía.
    if (password == null || password.isEmpty) {
      return 'La contraseña no puede estar vacía';
    }

    // Revisa si existe algún usuario con el correo electrónico introducido.
    if (possibleUser == null) {
      return 'No hay ninguna cuenta registrada con esta dirección de correo';
    }

    // Comprueba si la contraseña introducida coincide con la del usuario registrado.
    if (!BCrypt.checkpw(password, possibleUser.password!)) {
      return 'La contraseña no es correcta';
    }

    // Expresión regular para detectar números
    final RegExp numberRegExp = RegExp(r'\d'); 
    if (!numberRegExp.hasMatch(password)) {
      return 'La contraseña debe contener al menos un número';
    }

    return null; // No hay errores
  }

  static String? validatePasswordForSignUp(String password, String passwordRepeat) {
    // Verifica que la contraseña no esté vacía.
    if (password.isEmpty || passwordRepeat.isEmpty) {
      return 'La contraseña no puede estar vacía';
    }

    // Verifica que los campos "Contraseña" y "Repite tu cotraseña" coincidan.
    if (password != passwordRepeat) {
      return 'Las contraseñas no coinciden';
    }

    // Comprueba que la contraseña tenga la longitud mínima.
    if (password.length < minPassLength) {
      return 'La contraseña debe tener al menos $minPassLength caracteres';
    }

    // Expresión regular para detectar números
    final RegExp numberRegExp = RegExp(r'\d');
    if (!numberRegExp.hasMatch(password)) {
      return 'La contraseña debe contener al menos un número';
    }

    return null; // No hay errores
  }
}