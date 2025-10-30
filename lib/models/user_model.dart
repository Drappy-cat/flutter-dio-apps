class User {
  final int id;
  final String name;
  final String avatar;
  final String email;

  User({required this.id, required this.name, required this.avatar, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['first_name'] + ' ' + json['last_name'] as String,
      avatar: json['avatar'] as String,
      email: json['email'] as String,
    );
  }
}
