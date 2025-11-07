import 'package:flutter/material.dart';
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/modules/lainnya/pages/edit_profile_page.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({super.key});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  final AuthService authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      setState(() {
        _isLoading = true;
      });

      final success = await authService.logout();

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout gagal. Silakan coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ListTile> accountItems = [
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Pengaturan'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfilePage()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Keluar'),
        textColor: Colors.red,
        iconColor: Colors.red,
        trailing: const Icon(Icons.chevron_right),
        onTap: _handleLogout,
      ),
    ];

    return Stack(
      children: [
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
            child: ListView(
              shrinkWrap: true,
              children: accountItems,
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
