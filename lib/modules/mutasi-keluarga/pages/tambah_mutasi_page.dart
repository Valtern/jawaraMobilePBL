import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/widgets/tambah_mutasi_form.dart';

class TambahMutasiPage extends StatelessWidget {
  const TambahMutasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: const TambahMutasiForm(),
    );
  }
}
