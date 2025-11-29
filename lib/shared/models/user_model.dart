class User {
  final int id;
  final String name;
  final String email;
  final String? nik;
  final String? phone;
  final String role;
  final String status; 
  final String? fotoIdentitas;
  final String? fotoKtp; 

  final String? tempatLahir;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? agama;
  final String? statusPerkawinan;
  final String? pekerjaan;
  final int? wargaId; 
  
  final bool isFaceLoginEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.nik,
    this.phone,
    required this.role,
    required this.status,
    this.fotoIdentitas,
    this.fotoKtp,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.agama,
    this.statusPerkawinan,
    this.pekerjaan,
    this.wargaId,
    this.isFaceLoginEnabled = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Check if 'warga' relationship exists in JSON
    final wargaData = json['warga'] as Map<String, dynamic>?;
    
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      nik: json['nik'],
      phone: json['phone'],
      role: json['role'] ?? 'warga',
      status: json['status'] ?? 'active', // Provide default if missing
      fotoIdentitas: json['foto_identitas'],
      fotoKtp: json['foto_ktp'],
      
      // Flatten wargas data
      tempatLahir: wargaData?['tempat_lahir'],
      tanggalLahir: wargaData?['tanggal_lahir'],
      jenisKelamin: wargaData?['jenis_kelamin'],
      agama: wargaData?['agama'],
      statusPerkawinan: wargaData?['status_perkawinan'],
      pekerjaan: wargaData?['pekerjaan'],
      wargaId: wargaData?['id'], // This fixes the undefined_getter error
      
      // Parse Boolean (Laravel might send 1/0 or true/false)
      isFaceLoginEnabled: json['is_face_login_enabled'] == 1 || json['is_face_login_enabled'] == true,
    );
  }
}