import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ListTile> accountItems = [
      const ListTile(
        leading: Icon(Icons.settings),
        title: Text('Pengaturan'),
        trailing: Icon(Icons.chevron_right),
      ),
      ListTile(
        iconColor: Colors.red,
        textColor: Colors.red,
        leading: const Icon(Icons.logout),
        title: const Text('Keluar'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
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
