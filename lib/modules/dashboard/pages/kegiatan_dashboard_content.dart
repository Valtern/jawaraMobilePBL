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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                "Gagal memuat data: ${snapshot.error}",
                style: const TextStyle(fontFamily: 'Poppins'),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'Belum ada data kegiatan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }

        final rootData = snapshot.data!;
        final data = _safeMap(rootData['kegiatan']);

        final total = data['total'] ?? 0;
        final waktu = _safeMap(data['waktu']);
        final kategori = _safeMap(data['kategori']); 
        final pj = data['pj_terbanyak'] ?? '-';
        
        final rawChartData = data['chart_bulanan'] as List? ?? [];
        final chartData = rawChartData.map((e) {
          if (e is num) return e.toDouble();
          if (e is String) return double.tryParse(e) ?? 0.0;
          return 0.0;
        }).toList();

        // Calculate task counts for each category
        final totalKategori = kategori.values.fold<int>(0, (sum, val) => sum + (val is int ? val : int.tryParse(val.toString()) ?? 0));
        final selesai = waktu['selesai'] ?? 0;
        final hariIni = waktu['hari_ini'] ?? 0;
        final akanDatang = waktu['akan_datang'] ?? 0;
        final totalWaktu = (selesai is int ? selesai : int.tryParse(selesai.toString()) ?? 0) +
                          (hariIni is int ? hariIni : int.tryParse(hariIni.toString()) ?? 0) +
                          (akanDatang is int ? akanDatang : int.tryParse(akanDatang.toString()) ?? 0);

        // Prepare task groups for list
        final taskGroups = <Map<String, dynamic>>[];
        
        // Add total kegiatan first
        final totalInt = total is int ? total : int.tryParse(total.toString()) ?? 0;
        if (totalInt > 0) {
          taskGroups.add({
            'name': 'Total Kegiatan',
            'tasks': totalInt,
            'progress': 100.0,
            'icon': Icons.event_note,
            'color': Colors.blue,
          });
        }
        
        // Add kategori tasks
        kategori.forEach((key, value) {
          final count = value is int ? value : int.tryParse(value.toString()) ?? 0;
          if (count > 0 && totalKategori > 0) {
            taskGroups.add({
              'name': key,
              'tasks': count,
              'progress': (count / totalKategori * 100).clamp(0.0, 100.0),
              'icon': Icons.category,
              'color': _getColorForIndex(taskGroups.length),
            });
          }
        });

        // Add waktu tasks
        if (totalWaktu > 0) {
          taskGroups.add({
            'name': 'Waktu Pelaksanaan',
            'tasks': totalWaktu,
            'progress': 50.0,
            'icon': Icons.schedule,
            'color': Colors.amber,
          });
        }

        // Ensure at least one item for badge count
        final badgeCount = taskGroups.isEmpty ? 0 : taskGroups.length;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badge
              _buildSectionHeader('Kegiatan', badgeCount),
              const SizedBox(height: 8),
              Text(
                'Your today\'s task',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              
              // Task Groups List
              if (taskGroups.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Belum ada data kegiatan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF636E72),
                      ),
                    ),
                  ),
                )
              else
                ...taskGroups.map((group) => _buildTaskGroupCard(
                  group['name'] as String,
                  group['tasks'] as int,
                  group['progress'] as double,
                  group['icon'] as IconData,
                  group['color'] as Color,
                )).toList(),
              
              const SizedBox(height: 24),
              
              // Chart Card
              SizedBox(height: 300, child: _buildKegiatanPerBulanCard(chartData)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int badgeCount) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6938EF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            badgeCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  Widget _buildTaskGroupCard(String name, int tasks, double progress, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tasks Tasks',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
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
                    backgroundColor: color.withOpacity(0.2),
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