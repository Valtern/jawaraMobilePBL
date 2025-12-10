import 'package:flutter/material.dart';
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
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primary,
          tabs: const [
            Tab(text: 'Daftar Pengeluaran'),
            Tab(text: 'Tambah Pengeluaran'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DaftarPengeluaranPage(key: _daftarKey),
              TambahPengeluaranPage(onSuccess: _onPengeluaranAdded),
            ],
          ),
        ),
      ],
    );
  }
}