import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/widgets/edit_pengguna_form.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/widgets/pengguna_card.dart';

class EditPenggunaPage extends StatelessWidget {
  final PenggunaData user;
  const EditPenggunaPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Edit Pengguna',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: EditPenggunaForm(user: user),
    );
  }
}
