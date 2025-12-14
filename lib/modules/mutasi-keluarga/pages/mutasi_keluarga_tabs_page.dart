import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/consistent_tabbar.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/pages/daftar_mutasi_page.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/pages/tambah_mutasi_page.dart';

class MutasiKeluargaTabsPage extends StatelessWidget {
  const MutasiKeluargaTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConsistentTabBar(
      tabs: ['Daftar Mutasi', 'Tambah Mutasi'],
      tabViews: const [
        DaftarMutasiPage(),
        TambahMutasiPage(),
      ],
    );
  }
}
