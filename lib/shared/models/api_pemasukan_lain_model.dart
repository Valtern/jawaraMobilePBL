// lib/shared/models/api_pemasukan_lain_model.dart

class ApiPemasukanLain {
  final int id;
  final String name;
  final String jenis;
  final String nominal;
  final String tanggal;
  final String? keterangan;

  ApiPemasukanLain({
    required this.id,
    required this.name,
    required this.jenis,
    required this.nominal,
    required this.tanggal,
    this.keterangan,
  });

  factory ApiPemasukanLain.fromJson(Map<String, dynamic> json) {
    return ApiPemasukanLain(
      id: json['id'],
      name: json['name'],
      jenis: json['jenis'],
      nominal: json['nominal'],
      tanggal: json['tanggal'],
      keterangan: json['keterangan'],
    );
  }
}