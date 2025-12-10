import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/pages/daftar_mutasi_page.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/pages/tambah_mutasi_page.dart';

class MutasiKeluargaTabsPage extends StatelessWidget {
  const MutasiKeluargaTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          TabBar(
            labelColor: primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primary,
            tabs: const [
              Tab(text: 'Daftar Mutasi'),
              Tab(text: 'Tambah Mutasi'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [DaftarMutasiPage(), TambahMutasiPage()],
            ),
          ),
        ],
      ),
    );
  }
}
