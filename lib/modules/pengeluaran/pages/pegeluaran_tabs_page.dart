import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pengeluaran/pages/daftar.dart';
import 'package:jawarapbl/modules/pengeluaran/pages/tambah.dart';

class PengeluaranTabsPage extends StatelessWidget {
  const PengeluaranTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          const TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: 'Daftar Pengeluaran'),
              Tab(text: 'Tambah Pengeluaran'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [DaftarPengeluaranPage(), TambahPengeluaranPage()],
            ),
          ),
        ],
      ),
    );
  }
}
