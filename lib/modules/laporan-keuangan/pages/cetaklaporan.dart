import 'package:flutter/material.dart';
import '../widgets/cetaklaporan_widget.dart';

class CetakLaporanPage extends StatelessWidget {
  const CetakLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topLeft,
        // Gunakan ListView jika form bisa terlalu panjang
        child: SingleChildScrollView( 
          child: SizedBox(
            width: 600, // Batasi lebar form agar terlihat rapi seperti di web
            child: CetakLaporanForm(),
          ),
        ),
      ),
    );
  }
}