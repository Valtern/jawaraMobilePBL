import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/widgets/tambah_pengguna_form.dart';

class TambahPenggunaPage extends StatelessWidget {
  const TambahPenggunaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      // appBar: AppBar(
      //   title: const Text(
      //     'Tambah Akun Pengguna',
      //     style: TextStyle(
      //       color: Colors.deepPurple,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   backgroundColor: Colors.white,
      //   elevation: 2,
      //   iconTheme: const IconThemeData(color: Colors.deepPurple),
      //   automaticallyImplyLeading: false, // Remove back button for tab
      // ),
      body: const TambahPenggunaForm(),
    );
  }
}
