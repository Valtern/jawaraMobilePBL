class PengeluaranModel {
  final int no;
  final String nama;
  final String jenisPengeluaran;
  final String tanggal;
  final double nominal;

  const PengeluaranModel({
    required this.no,
    required this.nama,
    required this.jenisPengeluaran,
    required this.tanggal,
    required this.nominal,
  });

  // Metode bantu untuk format Rupiah sederhana (opsional)
  String get nominalRupiah => 'Rp ${nominal.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}