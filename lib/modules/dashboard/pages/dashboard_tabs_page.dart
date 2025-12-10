import 'package:flutter/material.dart';
import 'keuangan_dashboard_content.dart';
import 'kegiatan_dashboard_content.dart';
import 'kependudukan_dashboard_content.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final accent = theme.colorScheme.secondary;
    final softBackground = theme.colorScheme.background;

    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: softBackground,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: primary,
                          indicator: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primary, accent],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                          tabs: const [
                            Tab(text: 'Keuangan'),
                            Tab(text: 'Kegiatan'),
                            Tab(text: 'Kependudukan'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Expanded(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
