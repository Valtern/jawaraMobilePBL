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

  // Metode bantu untuk format Rupiah sederhana (opsional)
  String get nominalRupiah => 'Rp ${nominal.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}