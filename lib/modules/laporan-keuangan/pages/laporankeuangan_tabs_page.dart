import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/consistent_tabbar.dart';
import 'cetaklaporan.dart';
import 'semuapemasukan.dart';
import 'semuapengeluaran.dart';

class LaporanKeuanganTabsPage extends StatelessWidget {
  const LaporanKeuanganTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarTabBar(
      title: 'Laporan Keuangan',
      tabs: ['Cetak Laporan', 'Semua Pemasukan', 'Semua Pengeluaran'],
      tabViews: const [
        CetakLaporanPage(),
        SemuaPemasukanPage(),
        SemuaPengeluaranPage(),
      ],
      labelColor: const Color(0xFF673AB7),
      unselectedLabelColor: const Color(0xFF673AB7),
      indicatorColor: const Color(0xFF673AB7),
      foregroundColor: Colors.black,
    );
  }
}
