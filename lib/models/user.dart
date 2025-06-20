// models/user.dart
class User {
  final int? id;
  final String username;
  final String password;
  final String? profileImage;

  User({
    this.id,
    required this.username,
    required this.password,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'profile_image': profileImage,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      profileImage: map['profile_image'],
    );
  }
}