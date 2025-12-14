import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/consistent_tabbar.dart';
import 'keuangan_dashboard_content.dart';
import 'kegiatan_dashboard_content.dart';
import 'kependudukan_dashboard_content.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConsistentTabBar(
      tabs: ['Keuangan', 'Kegiatan', 'Kependudukan'],
      tabViews: [
        const KeuanganDashboardContent(),
        const KegiatanDashboardContent(),
        const KependudukanDashboardContent(),
      ],
    );
  }
}
