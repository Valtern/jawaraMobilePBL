import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jawarapbl/modules/dashboard/widget/kependudukan_card.dart';
import 'package:jawarapbl/services/dashboard_service.dart';

class KependudukanDashboardContent extends StatefulWidget {
  const KependudukanDashboardContent({super.key});

  @override
  State<KependudukanDashboardContent> createState() => _KependudukanDashboardContentState();
}

class _KependudukanDashboardContentState extends State<KependudukanDashboardContent> {
  final DashboardService _service = DashboardService();
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _service.getDashboardStats();
  }

  // HELPER: Safely convert dynamic data (List or Map) into Map<String, dynamic>
  Map<String, dynamic> _safeMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    // If API returns [] (empty list), we treat it as {}
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Use _safeMap to prevent crashes
        final rootData = snapshot.data ?? {};
        final data = _safeMap(rootData['kependudukan']);
        
        final totalKeluarga = data['total_keluarga']?.toString() ?? '0';
        final totalPenduduk = data['total_warga']?.toString() ?? '0';
        
        // Safely extract nested maps
        final genderData = _safeMap(data['gender']);
        final statusData = _safeMap(data['status']);
        
        // Calculate percentages
        int laki = int.tryParse(genderData['laki_laki']?.toString() ?? '0') ?? 0;
        int perempuan = int.tryParse(genderData['perempuan']?.toString() ?? '0') ?? 0;
        int totalGender = laki + perempuan;
        double lakiPct = totalGender == 0 ? 0 : (laki / totalGender) * 100;
        double prPct = totalGender == 0 ? 0 : (perempuan / totalGender) * 100;

        return GridView.count(
          padding: const EdgeInsets.all(16.0),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
          children: [
            _buildStatCard('Total Keluarga', Icons.group, Colors.blue.shade700, totalKeluarga),
            _buildStatCard('Total Penduduk', Icons.person, Colors.green.shade600, totalPenduduk),
            
            KependudukanCard(
              title: 'Jenis Kelamin',
              icon: Icons.wc,
              color: Colors.purple.shade600,
              height: 200,
              child: _buildPieChart(
                sections: [
                  PieChartSectionData(
                    color: Colors.blueAccent, 
                    value: laki.toDouble(), 
                    title: '${lakiPct.toStringAsFixed(0)}%', 
                    radius: 40, 
                    showTitle: true
                  ),
                  PieChartSectionData(
                    color: Colors.pinkAccent, 
                    value: perempuan.toDouble(), 
                    title: '${prPct.toStringAsFixed(0)}%', 
                    radius: 40, 
                    showTitle: true
                  ),
                ],
                legend: [
                  _buildLegendItem(Colors.blueAccent, 'Laki'),
                  _buildLegendItem(Colors.pinkAccent, 'Pr'),
                ]
              ),
            ),
            
             KependudukanCard(
              title: 'Status Perkawinan',
              icon: Icons.favorite,
              color: Colors.red.shade700,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Kawin: ${statusData['kawin'] ?? 0}"),
                  const SizedBox(height: 8),
                  Text("Belum: ${statusData['belum_kawin'] ?? 0}"),
                ],
              ), 
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color, String value) {
    return KependudukanCard(
      title: title,
      icon: icon,
      color: color,
      child: Center(
        child: Text(
          value,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPieChart({required List<PieChartSectionData> sections, required List<Widget> legend}) {
    if (sections.every((s) => s.value == 0)) {
       return const Center(child: Text("Belum ada data"));
    }
    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 20,
              sectionsSpace: 2,
            ),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: legend),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}