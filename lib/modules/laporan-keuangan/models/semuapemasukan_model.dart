// lib/modules/laporan-keuangan/models/semuapemasukan_model.dart

class PemasukanModel {
  final int no;
  final String nama;
  final String jenisPemasukan;
  final String tanggal;
  final double nominal;
  final DateTime tanggalSort; // ADDED: For sorting

  const PemasukanModel({
    required this.no,
    required this.nama,
    required this.jenisPemasukan,
    required this.tanggal,
    required this.nominal,
    required this.tanggalSort, // ADDED: To constructor
  });

  factory PemasukanModel.fromJson(Map<String, dynamic> json) {
    // This factory is now less relevant as the service uses the constructor,
    // but we update it for completeness.
    final tanggalString = json['tanggal'] ?? '1970-01-01';
    return PemasukanModel(
      no: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['name'] ?? '',
      jenisPemasukan: json['jenis'] ?? '',
      tanggal: tanggalString,
      nominal: json['nominal'] is double
          ? json['nominal']
          : double.tryParse(json['nominal'].toString()) ?? 0.0,
      // Attempt to parse sort date, fallback to 'tanggal' or epoch
      tanggalSort: DateTime.tryParse(json['tanggalSort'] ?? tanggalString) ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': no,
      'name': nama,
      'jenis': jenisPemasukan,
      'tanggal': tanggal,
      'nominal': nominal,
      'tanggalSort': tanggalSort.toIso8601String(), // ADDED: To JSON
    };
  }

  String get nominalRupiah =>
      'Rp ${nominal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}