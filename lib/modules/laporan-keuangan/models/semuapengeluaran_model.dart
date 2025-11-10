import 'dart:convert';

class PengeluaranModel {
  final int id;
  final String nama;
  final String kategori;
  final String tanggal;
  final double nominal;
  final String? deskripsi;

  const PengeluaranModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.tanggal,
    required this.nominal,
    this.deskripsi,
  });

  // Factory dari JSON (buat ambil data dari API Laravel)
  factory PengeluaranModel.fromJson(Map<String, dynamic> json) {
    return PengeluaranModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? '',
      tanggal: json['tanggal'] ?? '',
      nominal: double.tryParse(json['nominal'].toString()) ?? 0.0,
      deskripsi: json['deskripsi'],
    );
  }

  // Ubah ke JSON (buat POST / PUT ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'tanggal': tanggal,
      'nominal': nominal,
      'deskripsi': deskripsi,
    };
  }

  // Format nominal ke Rupiah tanpa desimal
  String get nominalRupiah {
    final formatted = nominal
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  // Parse list dari JSON (kalau API kirim banyak data)
  static List<PengeluaranModel> listFromJson(String jsonData) {
    final data = json.decode(jsonData);
    if (data is List) {
      return data.map((e) => PengeluaranModel.fromJson(e)).toList();
    } else if (data is Map) {
      // Handle jika response berbentuk map: {"0": {...}, "1": {...}}
      return data.values
          .map((e) => PengeluaranModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
