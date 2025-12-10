import 'package:flutter/material.dart';
import 'cetaklaporan.dart';
import 'semuapemasukan.dart';
import 'semuapengeluaran.dart';

class LaporanKeuanganTabsPage extends StatelessWidget {
  const LaporanKeuanganTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Keuangan'),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          bottom: TabBar(
            indicatorColor: primary,
            labelColor: primary,
            unselectedLabelColor: primary,
            tabs: const [
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