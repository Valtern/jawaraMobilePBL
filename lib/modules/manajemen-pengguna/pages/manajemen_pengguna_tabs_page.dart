import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/pages/daftar_pengguna_page.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/pages/tambah_pengguna_page.dart';

class ManajemenPenggunaTabsPage extends StatelessWidget {
  const ManajemenPenggunaTabsPage({super.key});

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
              Tab(text: 'Daftar Pengguna'),
              Tab(text: 'Tambah Pengguna'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [DaftarPenggunaPage(), TambahPenggunaPage()],
            ),
          ),
        ],
      ),
    );
  }
}
