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
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const TabBar(
              isScrollable: true,
              labelColor: Color(0xFF6938EF),
              unselectedLabelColor: Color(0xFF636E72),
              indicatorColor: Color(0xFF6938EF),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'Keuangan'),
                Tab(text: 'Kegiatan'),
                Tab(text: 'Kependudukan'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const ClampingScrollPhysics(),
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
