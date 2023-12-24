
class User {
  String? userName;
  String? mail;
  String? password;

  User(){}

  User.full({
    required this.userName,
    required this.mail,
    required this.password,
  });

  static List<User> registeredUsers = [];

  static Map<String, dynamic> toJson(User user) {
    return {
      'userName': user.userName,
      'mail': user.mail,
      'password': user.password,
    };
  }
  
  static User fromJson(Map<String, dynamic> json) {
    return User.full(
      userName: json['userName'] as String,
      mail: json['mail'] as String,
      password: json['password'] as String,
    );
  }
}