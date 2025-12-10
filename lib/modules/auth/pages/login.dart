import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/auth/widget/ImageSection.dart';
import 'package:jawarapbl/modules/auth/widget/LoginSection.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [ImageSection(), LoginForm()]),
      ),
    );
  }
}