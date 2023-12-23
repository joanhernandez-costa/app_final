
class User {
  String mail;
  String password;

  User({
    required this.mail,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'mail': mail,
      'password': password,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      mail: json['mail'],
      password: json['password'],
    );
  }
}