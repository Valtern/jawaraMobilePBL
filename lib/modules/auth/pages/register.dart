import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/auth/widget/RegisterSection.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan back arrow
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF6938EF),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Logo dan Title
            Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6938EF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(0),
                  child: Image.asset(
                    'assets/images/TransIconJawara.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Regitrasi Akun',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Register Form
            const Expanded(
              child: RegisterSection(),
            ),
          ],
        ),
      ),
    );
  }
}
