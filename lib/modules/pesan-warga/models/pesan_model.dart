class Pesan {
  final int id;
  final String judul;
  final String isi;
  final String status;
  final String tanggalKirim;
  final String pengirim;

  Pesan({
    required this.id,
    required this.judul,
    required this.isi,
    required this.status,
    required this.tanggalKirim,
    required this.pengirim,
  });

  factory Pesan.fromJson(Map<String, dynamic> json) {
    return Pesan(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      status: json['status'] ?? 'terkirim',
      tanggalKirim: json['tanggal_kirim'] ?? '',
      pengirim: json['pengirim'] ?? '-',
    );
  }
}