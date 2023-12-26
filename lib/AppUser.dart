
class AppUser {
  String? userName;
  String? mail;
  String? password;
  String? profileImage;
  String? userId;

  AppUser(){}

  AppUser.full({
    required this.userName,
    required this.mail,
    required this.password,
    this.profileImage,
    this.userId,
  });

  static List<AppUser> registeredUsers = [];

  static Map<String, dynamic> toJson(AppUser user) {
    return {
      'userName': user.userName,
      'mail': user.mail,
      'password': user.password,
      'profile_image_path': user.profileImage,
      'user_id': user.userId,
    };
  }
  
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser.full(
      userName: json['userName'] as String,
      mail: json['mail'] as String,
      password: json['password'] as String,
      profileImage: json['profile_image_path'] as String?,
      userId: json['user_id'] as String?,
    );
  }
}