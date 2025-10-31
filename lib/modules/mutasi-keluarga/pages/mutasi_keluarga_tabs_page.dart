import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/pages/daftar_mutasi_page.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/pages/tambah_mutasi_page.dart';

class MutasiKeluargaTabsPage extends StatelessWidget {
  const MutasiKeluargaTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const <Widget>[
          TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: 'Daftar Mutasi'),
              Tab(text: 'Tambah Mutasi'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [DaftarMutasiPage(), TambahMutasiPage()],
            ),
          ),
        ],
      ),
    );
  }
}
