import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pengeluaran/widgets/widgetTambah.dart';

class TambahPengeluaranPage extends StatelessWidget {
  final VoidCallback onSuccess;
  const TambahPengeluaranPage({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: TambahPengeluaranForm(
          onSuccess: onSuccess,
        ),
      ),
    );
  }
}
