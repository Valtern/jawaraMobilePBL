
class User {
  final int id;
  final String name;
  final String email;
  final String? fotoIdentitas; 
  final String role;
  final String status;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.fotoIdentitas,
    required this.role,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      fotoIdentitas: json['foto_identitas'],
      role: json['role'],
      status: json['status'],
    );
  }
}