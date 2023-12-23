
import 'package:app_final/SaveLoad.dart';

class User implements ObjectWithJson{
  String? mail;
  String? password;

  User(){}

  User.full({
    required this.mail,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'mail': mail,
      'password': password,
    };
  }
  
  static User fromJson(Map<String, dynamic> json) {
    return User.full(
      mail: json['mail'] as String? ?? '',
      password: json['password'] as String  ?? '',
    );
  }
}