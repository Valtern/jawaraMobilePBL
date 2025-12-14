import 'package:flutter/material.dart';
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/shared/widgets/consistent_tabbar.dart';
import 'package:jawarapbl/modules/pesan-warga/pages/informasiaspirasi.dart';
import 'package:jawarapbl/modules/pesan-warga/pages/kirim_pesan_page.dart';
import 'package:jawarapbl/modules/pesan-warga/pages/pesan_masuk_page.dart';

// Diubah menjadi StatefulWidget
class PesanWargaTabsPage extends StatefulWidget {
  const PesanWargaTabsPage({super.key});

  @override
  State<PesanWargaTabsPage> createState() => _PesanWargaTabsPageState();
}

class _PesanWargaTabsPageState extends State<PesanWargaTabsPage> {
  String? _userRole;
  bool _isLoading = true;

  final List<String> _tabs = [
    'Kotak Masuk',
    'Kirim Pesan',
  ];

  final List<Widget> _tabViews = [
    const PesanMasukPage(),
    const KirimPesanPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadRoleAndBuildTabs();
  }

  void _loadRoleAndBuildTabs() async {
    try {
      final role = await AuthService().getRole();
      setState(() {
        _userRole = role;

        // Tampilkan tab Aspirasi HANYA untuk admin, rw, dan rt
        if (_userRole == 'admin' || _userRole == 'rw' || _userRole == 'rt') {
          _tabs.add('Informasi Aspirasi');
          _tabViews.add(const AspirasiWargaPage());
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pesan Warga')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppBarTabBar(
      title: 'Pesan Warga',
      tabs: _tabs,
      tabViews: _tabViews,
    );
  }
}
