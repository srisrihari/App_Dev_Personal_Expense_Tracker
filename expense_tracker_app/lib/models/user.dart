class User {
  final String username;
  final String email;
  final String? password;

  User({
    required this.username,
    required this.email,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      if (password != null) 'password': password,
    };
  }
}
