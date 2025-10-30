// Model untuk Cetak Laporan biasanya tidak diperlukan jika hanya berfungsi sebagai form filter.
// Jika diperlukan model untuk menampung data laporan yang akan dicetak, definisikan di sini.
class CetakLaporanFilter {
  final DateTime? tanggalMulai;
  final DateTime? tanggalAkhir;
  final String? jenisLaporan; // 'Semua', 'Pemasukan', 'Pengeluaran'

  CetakLaporanFilter({
    this.tanggalMulai,
    this.tanggalAkhir,
    this.jenisLaporan,
  });
}