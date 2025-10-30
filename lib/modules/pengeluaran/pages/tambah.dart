import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pengeluaran/widgets/widgetTambah.dart';

class TambahPengeluaranPage extends StatelessWidget {
  const TambahPengeluaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 16.0),
        child: TambahPengeluaranForm(),
      ),
    );
  }
}
