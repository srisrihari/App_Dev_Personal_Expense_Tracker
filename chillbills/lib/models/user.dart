class User {
  final String id;
  final String email;
  final String name;
  final String username;
  final String photoUrl;

  User({
    required this.id, 
    required this.email,
    required this.name,
    required this.username,
    this.photoUrl = '',
  });

  // Generate a profile picture using the first letter of the name
  String get profilePicture {
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? json['email'].split('@').first,
      photoUrl: json['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'photoUrl': photoUrl,
    };
  }
}
