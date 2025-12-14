import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/widgets/tambah_mutasi_form.dart';

class TambahMutasiPage extends StatelessWidget {
  const TambahMutasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: const TambahMutasiForm(),
      ),
    );
  }
}
