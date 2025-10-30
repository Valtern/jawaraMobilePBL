import 'package:flutter/material.dart';
import 'penerimaanwarga.dart'; 

// Ganti nama kelas agar lebih spesifik (opsional, tergantung struktur Anda)
class PenerimaanWargaMasterPage extends StatelessWidget {
  const PenerimaanWargaMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penerimaan Warga'),
      ),
      body: const PenerimaanWargaPage(), 
    );
  }
}