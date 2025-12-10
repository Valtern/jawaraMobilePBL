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
        final pj = data['pj_terbanyak'] ?? '-';
        
        final rawChartData = data['chart_bulanan'] as List? ?? [];
        final chartData = rawChartData.map((e) {
          if (e is num) return e.toDouble();
          if (e is String) return double.tryParse(e) ?? 0.0;
          return 0.0;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.75,
                children: [
                  _buildTotalKegiatanCard(total is int ? total : int.tryParse(total.toString()) ?? 0),
                  _buildKegiatanPerKategoriCard(kategori),
                  _buildKegiatanByWaktuCard(waktu),
                  _buildPenanggungJawabCard(pj.toString()),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(height: 300, child: _buildKegiatanPerBulanCard(chartData)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalKegiatanCard(int total) {
    return DashboardCard(
      title: 'Total Kegiatan',
      icon: Icons.event_note,
      color: Colors.blue.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            total.toString(),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Event terdaftar',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildKegiatanPerKategoriCard(Map<String, dynamic> kategoriData) {
    final List<Color> colors = [Colors.blue, Colors.orange, Colors.red, Colors.purple, Colors.teal];
    int colorIndex = 0;

    List<Widget> categoryWidgets = kategoriData.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: _buildKategoriRow(color, '${entry.key}: ${entry.value}'),
      );
    }).toList();

    if (categoryWidgets.isEmpty) {
      categoryWidgets = [const Text("Belum ada data")];
    }

    return DashboardCard(
      title: 'Kategori',
      icon: Icons.category,
      color: Colors.green.shade700,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryWidgets,
        ),
      ),
    );
  }

  Widget _buildKategoriRow(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildKegiatanByWaktuCard(Map<String, dynamic> waktuData) {
    return DashboardCard(
      title: 'Waktu Pelaksanaan',
      icon: Icons.schedule,
      color: Colors.amber.shade800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Selesai: ${waktuData['selesai'] ?? 0}'),
          const SizedBox(height: 8),
          Text(
            'Hari Ini: ${waktuData['hari_ini'] ?? 0}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text('Akan Datang: ${waktuData['akan_datang'] ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildPenanggungJawabCard(String nama) {
    return DashboardCard(
      title: 'PJ Teraktif',
      icon: Icons.person,
      color: Colors.purple.shade700,
      child: Center(
        child: Text(
          nama,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
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