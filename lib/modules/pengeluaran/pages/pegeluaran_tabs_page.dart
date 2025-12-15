import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/consistent_tabbar.dart';
import 'package:jawarapbl/modules/pengeluaran/pages/daftar.dart';
import 'package:jawarapbl/modules/pengeluaran/pages/tambah.dart';

class PengeluaranTabsPage extends StatefulWidget {
  const PengeluaranTabsPage({super.key});

  @override
  State<PengeluaranTabsPage> createState() => _PengeluaranTabsPageState();
}

class _PengeluaranTabsPageState extends State<PengeluaranTabsPage>
    with SingleTickerProviderStateMixin {
  // Key to access the Daftar page's state and call refreshData()
  final GlobalKey<DaftarPengeluaranPageState> _daftarKey =
      GlobalKey<DaftarPengeluaranPageState>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onPengeluaranAdded() {
    // Refresh the list
    _daftarKey.currentState?.refreshData();
    // Switch back to the list tab
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return ConsistentTabBar(
      tabs: ['Daftar Pengeluaran', 'Tambah Pengeluaran'],
      tabViews: [
        DaftarPengeluaranPage(key: _daftarKey),
        TambahPengeluaranPage(onSuccess: _onPengeluaranAdded),
      ],
    );
  }
}
