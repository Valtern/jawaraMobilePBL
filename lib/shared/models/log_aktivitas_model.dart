class LogAktivitas {
  final int id;
  final int? userId;
  final String userName;
  final String kategori;
  final String deskripsi;
  final String createdAt;
  final String tanggal;

  LogAktivitas({
    required this.id,
    this.userId,
    required this.userName,
    required this.kategori,
    required this.deskripsi,
    required this.createdAt,
    required this.tanggal,
  });

  factory LogAktivitas.fromJson(Map<String, dynamic> json) {
    return LogAktivitas(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'System',
      kategori: json['kategori'],
      deskripsi: json['deskripsi'],
      createdAt: json['created_at'],
      tanggal: json['tanggal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'created_at': createdAt,
      'tanggal': tanggal,
    };
  }
}
