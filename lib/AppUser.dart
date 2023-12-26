
import 'dart:io';

class AppUser {
  String? userName;
  String? mail;
  String? password;
  String? profileImage;

  AppUser(){}

  AppUser.full({
    required this.userName,
    required this.mail,
    required this.password,
    this.profileImage,
  });

  AppUser.singingIn({
    required this.userName,
    required this.password,
  });

  static List<AppUser> registeredUsers = [];

  static Map<String, dynamic> toJson(AppUser user) {
    return {
      'userName': user.userName,
      'mail': user.mail,
      'password': user.password,
      'profile_image_path': user.profileImage,
    };
  }
  
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser.full(
      userName: json['userName'] as String,
      mail: json['mail'] as String,
      password: json['password'] as String,
      profileImage: json['profile_image_path'] as String?,
    );
  }
}