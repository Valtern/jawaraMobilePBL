import 'package:flutter/material.dart';
import 'keuangan_dashboard_content.dart';
import 'kegiatan_dashboard_content.dart';
import 'kependudukan_dashboard_content.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: const [
          TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: 'Keuangan'),
              Tab(text: 'Kegiatan'),
              Tab(text: 'Kependudukan'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                KeuanganDashboardContent(),
                KegiatanDashboardContent(),
                KependudukanDashboardContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
