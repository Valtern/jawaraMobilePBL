import 'package:flutter/material.dart';
import 'package:jawarapbl/services/auth_services.dart';

class MenusCard extends StatefulWidget {
  const MenusCard({super.key});

  @override
  State<MenusCard> createState() => _MenusCardState();
}

class _MenusCardState extends State<MenusCard> {
  String? _role;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _authService.getRole();
    if (mounted) {
      setState(() {
        _role = role;
      });
    }
  }

  bool _canAccess(List<String> allowedRoles) {
    // If role is not loaded yet, hide everything except 'all' (optional)
    if (_role == null) return false;
    if (allowedRoles.contains('all')) return true;
    return allowedRoles.contains(_role);
  }

  @override
  Widget build(BuildContext context) {
    // Define roles for cleaner usage
    const admin = 'admin';
    const rw = 'rw';           
    const rt = 'rt';           
    const bendahara = 'bendahara';
    const sekretaris = 'sekretaris';
    // Warga is implicit as basic user, usually only sees 'all' items or specific 'warga' items

    final List<Map<String, dynamic>> menuConfiguration = [
      {
        'roles': ['all'],
        'widget': ListTile(
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
      },
      {
        'roles': [admin, rw, rt, sekretaris],
        'widget': ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Data Warga & Rumah'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/data-warga-rumah');
          },
        ),
      },
      {
        'roles': [admin, rw, rt, sekretaris],
        'widget': ListTile(
          leading: const Icon(Icons.calendar_month),
          title: const Text('Kegiatan & Broadcast'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/kegiatan-broadcast');
          },
        ),
      },
      {
        'roles': [admin, bendahara],
        'widget': ListTile(
          leading: const Icon(Icons.credit_card),
          title: const Text('Channel Transfer'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/channel-transfer');
          },
        ),
      },
      {
        'roles': [admin, bendahara, rw, rt],
        'widget': ListTile(
          leading: const Icon(Icons.show_chart),
          title: const Text('Laporan Keuangan'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/laporan-keuangan');
          },
        ),
      },
      {
        'roles': ['all'],
        'widget': ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Pesan Warga'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/pesan-warga');
          },
        ),
      },
      {
        'roles': [admin, rw, rt, sekretaris],
        'widget': ListTile(
          leading: const Icon(Icons.how_to_reg),
          title: const Text('Penerimaan Warga'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/penerimaan-warga');
          },
        ),
      },
      {
        'roles': [admin, rw, rt, sekretaris],
        'widget': ListTile(
          leading: const Icon(Icons.family_restroom),
          title: const Text('Mutasi Keluarga'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/mutasi-keluarga');
          },
        ),
      },
      {
        'roles': [admin],
        'widget': ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Log Aktivitas'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/log-aktivitas');
          },
        ),
      },
      {
        'roles': [admin],
        'widget': ListTile(
          leading: const Icon(Icons.admin_panel_settings),
          title: const Text('Manajemen Pengguna'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed('/manajemen-pengguna');
          },
        ),
      },
    ];

    // Filter menu items based on role
    final List<Widget> visibleMenuItems = menuConfiguration
        .where((item) => _canAccess(item['roles'] as List<String>))
        .map((item) => item['widget'] as Widget)
        .toList();

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
        child: _role == null
            ? const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ))
            : ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: visibleMenuItems,
              ),
      ),
    );
  }
}