import 'package:flutter/material.dart';
import 'cetaklaporan.dart';
import 'semuapemasukan.dart';
import 'semuapengeluaran.dart';

// Ganti nama kelas dari PesanWargaTabsPage menjadi LaporanKeuanganTabsPage
class LaporanKeuanganTabsPage extends StatelessWidget {
  const LaporanKeuanganTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Jumlah tab: Cetak Laporan, Pemasukan, Pengeluaran
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Keuangan'),
          // backgroundColor: Colors.deepPurple, // Contoh warna AppBar
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          bottom: const TabBar(
            indicatorColor: Color(0xFF673AB7),
            labelColor: Color(0xFF673AB7),
            unselectedLabelColor: Color(0xFF673AB7),
            tabs: [
              Tab(text: 'Cetak Laporan'),
              Tab(text: 'Semua Pemasukan'),
              Tab(text: 'Semua Pengeluaran'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CetakLaporanPage(),    // Konten untuk Tab 1 (Cetak Laporan)
            SemuaPemasukanPage(),  // Konten untuk Tab 2 (Semua Pemasukan)
            SemuaPengeluaranPage(), // Konten untuk Tab 3 (Semua Pengeluaran)
          ],
        ),
      ),
    );
  }
}