// lib/modules/pengeluaran/pages/edit_pengeluaran_page.dart

import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pengeluaran/widgets/widgetTambah.dart';
import 'package:jawarapbl/shared/models/pengeluaran_model.dart';

class EditPengeluaranPage extends StatelessWidget {
  final Pengeluaran pengeluaran;
  const EditPengeluaranPage({super.key, required this.pengeluaran});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pengeluaran'),
        backgroundColor: Colors.grey[100],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: TambahPengeluaranForm(
          pengeluaranToEdit: pengeluaran,
          onSuccess: () {
            // Pop with 'true' to signal success
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
  }
}