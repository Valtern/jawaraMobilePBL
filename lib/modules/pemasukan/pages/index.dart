import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pemasukan/pages/kategori_iuran.dart';
import 'package:jawarapbl/modules/pemasukan/pages/pemasukan_lain.dart';
import 'package:jawarapbl/modules/pemasukan/pages/tagihan.dart';

class PemasukanKategoriIuranPage extends StatelessWidget {
  const PemasukanKategoriIuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            labelColor: primary,
            unselectedLabelColor: Colors.black54,
            indicatorColor: primary,
            tabs: const [
              Tab(text: 'Kategori Iuran'),
              Tab(text: 'Tagihan'),
              Tab(text: 'Pemasukan Lain'),
            ],
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: TabBarView(
              children: [
                KategoriIuranListView(),
                TagihanListView(),
                PemasukanLainListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
