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

    final List<Map<String, dynamic>> menuConfiguration = [
      {
        'roles': ['all'],
        'widget': _buildModernMenuItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
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
        'widget': _buildModernMenuItem(
          icon: Icons.person,
          title: 'Data Warga & Rumah',
          onTap: () {
            Navigator.of(context).pushNamed('/data-warga-rumah');
          },
        ),
      },
      {
        'roles': ['all'],
        'widget': _buildModernMenuItem(
          icon: Icons.calendar_month,
          title: 'Kegiatan & Broadcast',
          onTap: () {
            Navigator.of(context).pushNamed('/kegiatan-broadcast');
          },
        ),
      },
      {
        'roles': [admin, bendahara],
        'widget': _buildModernMenuItem(
          icon: Icons.credit_card,
          title: 'Channel Transfer',
          onTap: () {
            Navigator.of(context).pushNamed('/channel-transfer');
          },
        ),
      },
      {
        'roles': [admin, bendahara, rw, rt],
        'widget': _buildModernMenuItem(
          icon: Icons.show_chart,
          title: 'Laporan Keuangan',
          onTap: () {
            Navigator.of(context).pushNamed('/laporan-keuangan');
          },
        ),
      },
      {
        'roles': ['all'],
        'widget': _buildModernMenuItem(
          icon: Icons.email,
          title: 'Pesan Warga',
          onTap: () {
            Navigator.of(context).pushNamed('/pesan-warga');
          },
        ),
      },
      {
        'roles': [admin, rw, rt, sekretaris],
        'widget': _buildModernMenuItem(
          icon: Icons.how_to_reg,
          title: 'Penerimaan Warga',
          onTap: () {
            Navigator.of(context).pushNamed('/penerimaan-warga');
          },
        ),
      },
      {
        'roles': [admin, rw, rt, sekretaris],
        'widget': _buildModernMenuItem(
          icon: Icons.family_restroom,
          title: 'Mutasi Keluarga',
          onTap: () {
            Navigator.of(context).pushNamed('/mutasi-keluarga');
          },
        ),
      },
      {
        'roles': [admin],
        'widget': _buildModernMenuItem(
          icon: Icons.history,
          title: 'Log Aktivitas',
          onTap: () {
            Navigator.of(context).pushNamed('/log-aktivitas');
          },
        ),
      },
      {
        'roles': [admin],
        'widget': _buildModernMenuItem(
          icon: Icons.admin_panel_settings,
          title: 'Manajemen Pengguna',
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _role == null
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6938EF)),
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: visibleMenuItems,
            ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF6938EF),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}