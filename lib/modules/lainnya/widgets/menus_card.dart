import 'package:flutter/material.dart';

class MenusCard extends StatelessWidget {
  const MenusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ListTile> menuItems = [
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        },
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Data Warga & Rumah'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed('/data-warga-rumah');
        },
      ),
      ListTile(
        leading: const Icon(Icons.calendar_month),
        title: const Text('Kegiatan & Broadcast'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed('/kegiatan-broadcast');
        },
      ),
      ListTile(
        leading: const Icon(Icons.credit_card),
        title: const Text('Channel Transfer'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed('/channel-transfer');
        },
      ),
      ListTile(
        leading: const Icon(Icons.show_chart),
        title: const Text('Laporan Keuangan'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed('/laporan-keuangan'); // ikon yang revelan
        },
      ),
      ListTile(
        leading: const Icon(Icons.email),
        title: const Text('Pesan Warga'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed('/pesan-warga');
        },
      ),
      ListTile(
        leading: const Icon(Icons.how_to_reg),
        title: const Text('Penerimaan Warga'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed('/penerimaan-warga');
        },
      ),
      ListTile(
        leading: const Icon(Icons.family_restroom),
        title: const Text('Mutasi Keluarga'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed('/mutasi-keluarga');
        },
      ),
      ListTile(
        leading: const Icon(Icons.history),
        title: const Text('Log Aktivitas'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed('/log-aktivitas');
        },
      ),
      ListTile(
        leading: const Icon(Icons.admin_panel_settings),
        title: const Text('Manajemen Pengguna'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed('/manajemen-pengguna');
        },
      ),
    ];

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
        child: ListView(shrinkWrap: true, children: menuItems),
      ),
    );
  }
}
