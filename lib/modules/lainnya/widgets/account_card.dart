import 'package:flutter/material.dart';
import 'package:jawarapbl/services/auth_services.dart';
// Import the new page
import 'package:jawarapbl/modules/lainnya/pages/edit_profile_page.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    final List<ListTile> accountItems = [
      ListTile(
        leading: const Icon(Icons.settings), // <-- Kept your original icon
        title: const Text('Pengaturan'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // MODIFIED: Changed this to navigate to the new page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfilePage()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout), // <-- Kept your original icon
        title: const Text('Keluar'),
        textColor: Colors.red,
        iconColor: Colors.red,
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await authService.logout();
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        },
      ),
    ];

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
        child: ListView(shrinkWrap: true, children: accountItems),
      ),
    );
  }
}