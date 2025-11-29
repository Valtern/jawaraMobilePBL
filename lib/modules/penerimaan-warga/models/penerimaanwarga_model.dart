class PenerimaanWarga {
  final int id;
  final String nama;
  final String email;
  final String nik;
  final String jenisKelamin;
  final String statusRegistrasi;
  final String tanggalDibuat;
  final String? fotoIdentitasUrl;

  PenerimaanWarga({
    required this.id,
    required this.nama,
    required this.email,
    required this.nik,
    required this.jenisKelamin,
    required this.statusRegistrasi,
    required this.tanggalDibuat,
    this.fotoIdentitasUrl,
  });

  factory PenerimaanWarga.fromJson(Map<String, dynamic> json) {
    return PenerimaanWarga(
      id: json['id'] ?? 0,
      nama: json['name'] ?? '',
      email: json['email'] ?? '',
      nik: json['nik'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      statusRegistrasi: json['status_registrasi'] ?? '',
      tanggalDibuat: json['created_at'] ?? '',
      fotoIdentitasUrl: json['foto_identitas_url'],
    );
  }
}
