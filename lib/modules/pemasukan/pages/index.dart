import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pemasukan/pages/kategori_iuran.dart';
import 'package:jawarapbl/modules/pemasukan/pages/pemasukan_lain.dart';
import 'package:jawarapbl/modules/pemasukan/pages/tagihan.dart';

class PemasukanKategoriIuranPage extends StatelessWidget {
  const PemasukanKategoriIuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          TabBar(
            isScrollable: true,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: 'Kategori Iuran'),
              Tab(text: 'Tagihan'),
              Tab(text: 'Pemasukan Lain'),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
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
