import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/consistent_tabbar.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/pages/daftar_pengguna_page.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/pages/tambah_pengguna_page.dart';

class ManajemenPenggunaTabsPage extends StatelessWidget {
  const ManajemenPenggunaTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConsistentTabBar(
      tabs: ['Daftar Pengguna', 'Tambah Pengguna'],
      tabViews: const [
        DaftarPenggunaPage(),
        TambahPenggunaPage(),
      ],
    );
  }
}
