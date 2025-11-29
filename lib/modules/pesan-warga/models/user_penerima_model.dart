class UserPenerima {
  final int id;
  final String namaLengkap;
  final String role;

  UserPenerima({
    required this.id,
    required this.namaLengkap,
    required this.role,
  });

  factory UserPenerima.fromJson(Map<String, dynamic> json) {
    return UserPenerima(
      id: json['id'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? 'Tanpa Nama',
      role: json['role'] ?? 'Warga',
    );
  }
}