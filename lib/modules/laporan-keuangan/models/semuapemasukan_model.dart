class PemasukanModel {
  final int no;
  final String nama;
  final String jenisPemasukan;
  final String tanggal;
  final double nominal;

  const PemasukanModel({
    required this.no,
    required this.nama,
    required this.jenisPemasukan,
    required this.tanggal,
    required this.nominal,
  });

  factory PemasukanModel.fromJson(Map<String, dynamic> json) {
    return PemasukanModel(
      no: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['name'] ?? '',
      jenisPemasukan: json['jenis'] ?? '',
      tanggal: json['tanggal'] ?? '',
      nominal: json['nominal'] is double
          ? json['nominal']
          : double.tryParse(json['nominal'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': no,
      'name': nama,
      'jenis': jenisPemasukan,
      'tanggal': tanggal,
      'nominal': nominal,
    };
  }

  String get nominalRupiah =>
      'Rp ${nominal.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}




