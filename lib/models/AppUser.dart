
import 'package:app_final/models/UserData.dart';

class AppUser {
  String? id;
  String userName;
  String? mail;
  String? password;  
  String? profileImageUrl;
  UserData? userData;

  AppUser({
    required this.userName,
    required this.mail,
    required this.password,
    required this.id,
    required this.profileImageUrl,
  });

  static Map<String, dynamic> toJson(AppUser user) {
    return {
      'userName': user.userName,
      'mail': user.mail,
      'password': user.password,
      'user_id': user.id,
      'profileImageUrl': user.profileImageUrl,
    };
  }
  
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      userName: json['userName'] as String,
      mail: json['mail'] as String? ?? 'Desconocido',
      password: json['password'] as String? ?? 'Desconocido',
      id: json['user_id'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? 'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/logo_recortado.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL2xvZ29fcmVjb3J0YWRvLnBuZyIsImlhdCI6MTcxMTgxNzM4NCwiZXhwIjoxNzQzMzUzMzg0fQ.l2nZWZtggW15CK6qX88ZS7poZvHNdOrecQsVyBOjsx0&t=2024-03-30T16%3A49%3A47.703Z',
    );
  }
}
