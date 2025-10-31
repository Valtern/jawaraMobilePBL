import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/widgets/daftar_pengguna_content.dart';

class DaftarPenggunaPage extends StatelessWidget {
  const DaftarPenggunaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FB),
      body: DaftarPenggunaContent(),
    );
  }
}
