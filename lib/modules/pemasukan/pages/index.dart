import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/consistent_tabbar.dart';
import 'package:jawarapbl/modules/pemasukan/pages/kategori_iuran.dart';
import 'package:jawarapbl/modules/pemasukan/pages/pemasukan_lain.dart';
import 'package:jawarapbl/modules/pemasukan/pages/tagihan.dart';

class PemasukanKategoriIuranPage extends StatelessWidget {
  const PemasukanKategoriIuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConsistentTabBar(
      tabs: ['Kategori Iuran', 'Tagihan', 'Pemasukan Lain'],
      tabViews: const [
        KategoriIuranListView(),
        TagihanListView(),
        PemasukanLainListView(),
      ],
    );
  }
}
