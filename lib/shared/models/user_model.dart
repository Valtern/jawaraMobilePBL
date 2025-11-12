class User {
  final int id;
  final String name;
  final String email;
  final String? nik;
  final String? phone;
  final String? fotoIdentitas;
  final String role;
  final String status;

  final String? tempatLahir;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? agama;
  final String? statusPerkawinan;
  final String? pekerjaan;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.nik,
    this.phone,
    this.fotoIdentitas,
    required this.role,
    required this.status,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.agama,
    this.statusPerkawinan,
    this.pekerjaan,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final wargaData = json['warga'] as Map<String, dynamic>?;

    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      nik: json['nik'],
      phone: json['phone'],
      fotoIdentitas: json['foto_identitas'],
      role: json['role'],
      status: json['status'],
      
      // Use data from the nested 'warga' object if it exists
      tempatLahir: wargaData?['tempat_lahir'],
      tanggalLahir: wargaData?['tanggal_lahir'],
      jenisKelamin: wargaData?['jenis_kelamin'],
      agama: wargaData?['agama'],
      statusPerkawinan: wargaData?['status_perkawinan'],
      pekerjaan: wargaData?['pekerjaan'],
    );
  }
}