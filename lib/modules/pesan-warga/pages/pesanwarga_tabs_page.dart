// folder pesan-warga folder pages file pesanwarga_master_page.dart (nama lebih akurat)
import 'package:flutter/material.dart';
import 'informasiaspirasi.dart'; // Import AspirasiWargaPage

// Ganti nama kelas jika file Anda adalah master page untuk Pesan Warga
class PesanWargaTabsPage extends StatelessWidget {
  const PesanWargaTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Jika AspirasiWargaPage adalah konten utama tanpa TabBar
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aspirasi Warga'),
      ),
      body: const AspirasiWargaPage(),
    );
  }
}
