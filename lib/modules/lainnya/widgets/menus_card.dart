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
    if (_role == null) return false;
    if (allowedRoles.contains('all')) return true;
    return allowedRoles.contains(_role);
  }

  @override
  Widget build(BuildContext context) {
    const admin = 'admin';
    const rw = 'rw';           
    const rt = 'rt';           
    const bendahara = 'bendahara';
    const sekretaris = 'sekretaris';

    final primary = Theme.of(context).colorScheme.primary;

    final List<Map<String, dynamic>> menuConfiguration = [
      {
        'roles': ['all'],
        'widget': ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.dashboard,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Dashboard',
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
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Data Warga & Rumah',
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
            Navigator.of(context).pushNamed('/data-warga-rumah');
          },
        ),
      },
      {
        'roles': ['all'],
        'widget': ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Kegiatan & Broadcast',
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
            Navigator.of(context).pushNamed('/kegiatan-broadcast');
          },
        ),
      },
      {
        'roles': [admin, bendahara],
        'widget': ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.credit_card,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Channel Transfer',
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
            Navigator.of(context).pushNamed('/channel-transfer');
          },
        ),
      },
      {
        'roles': [admin, bendahara, rw, rt],
        'widget': ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.show_chart,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Laporan Keuangan',
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
            Navigator.of(context).pushNamed('/laporan-keuangan');
          },
        ),
      },
      {
        'roles': ['all'],
        'widget': ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.email,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Pesan Warga',
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
            Navigator.of(context).pushNamed('/pesan-warga');
          },
        ),
      },
      {
        'roles': [admin, rw, rt, sekretaris],
        'widget': ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.how_to_reg,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Penerimaan Warga',
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
            Navigator.of(context).pushNamed('/penerimaan-warga');
          },
        ),
      },
      {
        'roles': [admin, rw, rt, sekretaris],
        'widget': ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.family_restroom,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Mutasi Keluarga',
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
            Navigator.of(context).pushNamed('/mutasi-keluarga');
          },
        ),
      },
      {
        'roles': [admin],
        'widget': ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Log Aktivitas',
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
            Navigator.of(context).pushNamed('/log-aktivitas');
          },
        ),
      },
      {
        'roles': [admin],
        'widget': ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: primary,
              size: 20,
            ),
          ),
          title: const Text(
            'Manajemen Pengguna',
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
            Navigator.of(context).pushNamed('/manajemen-pengguna');
          },
        ),
      },
    ];

    final List<Widget> visibleMenuItems = menuConfiguration
        .where((item) => _canAccess(item['roles'] as List<String>))
        .map((item) => item['widget'] as Widget)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: _role == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: visibleMenuItems,
              ),
      ),
    );
  }
}