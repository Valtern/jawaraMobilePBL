import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/widgets/tambah_mutasi_form.dart';

class TambahMutasiPage extends StatelessWidget {
  const TambahMutasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Mutasi Keluarga',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        automaticallyImplyLeading: false, // Remove back button if it's in a tab
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: const TambahMutasiForm(),
    );
  }
}
