import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/auth/widget/RegisterSection.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kembali'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: const RegisterSection(),
    );
  }
}
