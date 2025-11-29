class AspirasiWarga {
  final int id;
  final String judul;
  final String deskripsi;
  final String status;
  final String? pengirim;
  final String? tanggalDibuat;
  final int wargaId; 

  AspirasiWarga({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    this.pengirim,
    this.tanggalDibuat,
    required this.wargaId,
  });

  factory AspirasiWarga.fromJson(Map<String, dynamic> json) {
    return AspirasiWarga(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      status: json['status'] ?? '',
      pengirim:
          json['warga']?['nama_lengkap'] ?? '-',
      tanggalDibuat: json['created_at'] ?? '',
      wargaId: json['warga_id'] ?? 0, 
    );
  }
}