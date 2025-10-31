import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/widgets/daftar_mutasi_content.dart';

class DaftarMutasiPage extends StatelessWidget {
  const DaftarMutasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FB),
      body: DaftarMutasiContent(),
    );
  }
}
