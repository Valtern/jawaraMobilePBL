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
    final primary = Theme.of(context).colorScheme.primary;

    final List<ListTile> accountItems = [
      ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.settings,
            color: primary,
            size: 20,
          ),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfilePage()),
          );
        },
      ),
      ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.logout,
            color: Colors.red,
            size: 20,
          ),
        ),
        title: const Text(
          'Keluar',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.red,
        ),
        onTap: _handleLogout,
      ),
    ];

    return Stack(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
