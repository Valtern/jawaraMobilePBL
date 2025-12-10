import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jawarapbl/modules/dashboard/widget/kegiatan_widget.dart';
import 'package:jawarapbl/services/dashboard_service.dart';

class KegiatanDashboardContent extends StatefulWidget {
  const KegiatanDashboardContent({super.key});

  @override
  State<KegiatanDashboardContent> createState() => _KegiatanDashboardContentState();
}

class _KegiatanDashboardContentState extends State<KegiatanDashboardContent> {
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
        }
        if (snapshot.hasError) {
          return Center(child: Text("Gagal memuat data: ${snapshot.error}"));
        }

        final rootData = snapshot.data ?? {};
        final data = _safeMap(rootData['kegiatan']);

        final total = data['total'] ?? 0;
        final waktu = _safeMap(data['waktu']);
        // Fix: Use safeMap here to prevent List<dynamic> crash
        final kategori = _safeMap(data['kategori']);
        
        final rawChartData = data['chart_bulanan'] as List? ?? [];
        final chartData = rawChartData.map((e) {
          if (e is num) return e.toDouble();
          if (e is String) return double.tryParse(e) ?? 0.0;
          return 0.0;
        }).toList();

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // In Progress Section with Horizontal Scroll
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'In Progress',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    '${waktu['akan_datang'] ?? 0}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6938EF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildInProgressCard('Kegiatan', 'Total kegiatan terdaftar', total is int ? total : int.tryParse(total.toString()) ?? 0, const Color(0xFF2196F3), Icons.event_note),
                    _buildInProgressCard('Kategori', 'Berbagai kategori kegiatan', kategori.length, const Color(0xFFFF9800), Icons.category),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Task Groups Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Groups',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    '4',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6938EF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTaskGroupCard('Total Kegiatan', total is int ? total : int.tryParse(total.toString()) ?? 0, total, const Color(0xFFE91E63), Icons.event_note),
              const SizedBox(height: 12),
              _buildTaskGroupCard('Kegiatan Per Kategori', kategori.length, kategori.length, const Color(0xFF9C27B0), Icons.category),
              const SizedBox(height: 12),
              _buildTaskGroupCard('Waktu Pelaksanaan', waktu['selesai'] ?? 0, total, const Color(0xFFFF9800), Icons.schedule),
              const SizedBox(height: 12),
              _buildTaskGroupCard('PJ Teraktif', 1, 1, const Color(0xFFFFC107), Icons.person),
              const SizedBox(height: 16),
              SizedBox(height: 300, child: _buildKegiatanPerBulanCard(chartData)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInProgressCard(String title, String subtitle, int value, Color color, IconData icon) {
    final progress = value > 0 ? (value / 10 * 100).clamp(0.0, 100.0) : 0.0;
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF636E72),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskGroupCard(String title, int completed, int total, Color color, IconData icon) {
    final progress = total > 0 ? (completed / total * 100).clamp(0.0, 100.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed Tasks',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 6,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '${progress.toInt()}%',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildKegiatanPerBulanCard(List<double> data) {
    if (data.isEmpty || data.every((e) => e == 0)) {
       return DashboardCard(
        title: 'Tren Kegiatan (Tahun Ini)',
        icon: Icons.show_chart,
        color: Colors.pink.shade700,
        child: const Center(child: Text("Belum ada data grafik")),
      );
    }

    return DashboardCard(
      title: 'Tren Kegiatan (Tahun Ini)',
      icon: Icons.show_chart,
      color: Colors.pink.shade700,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 8.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 24, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)))),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                    int index = value.toInt();
                    if (index >= 0 && index < 12) return Text(months[index], style: const TextStyle(fontSize: 10));
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
                isCurved: true,
                color: Colors.pink,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: true, color: Colors.pink.withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}