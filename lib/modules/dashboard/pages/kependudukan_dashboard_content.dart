import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildModernStatCard('Total Keluarga', Icons.group, const Color(0xFF2196F3), totalKeluarga),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernStatCard('Total Penduduk', Icons.person, const Color(0xFF4CAF50), totalPenduduk),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Jenis Kelamin Card
              Container(
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
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.wc, color: Color(0xFF9C27B0), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Jenis Kelamin',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: _buildPieChart(
                        sections: [
                          PieChartSectionData(
                            color: const Color(0xFF2196F3), 
                            value: laki.toDouble(), 
                            title: '${lakiPct.toStringAsFixed(0)}%', 
                            radius: 50, 
                            showTitle: true
                          ),
                          PieChartSectionData(
                            color: const Color(0xFFE91E63), 
                            value: perempuan.toDouble(), 
                            title: '${prPct.toStringAsFixed(0)}%', 
                            radius: 50, 
                            showTitle: true
                          ),
                        ],
                        legend: [
                          _buildLegendItem(const Color(0xFF2196F3), 'Laki-laki'),
                          _buildLegendItem(const Color(0xFFE91E63), 'Perempuan'),
                        ]
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Status Perkawinan Card
              Container(
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
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF44336).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.favorite, color: Color(0xFFF44336), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Status Perkawinan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusItem('Kawin', statusData['kawin'] ?? 0, const Color(0xFF4CAF50)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatusItem('Belum Kawin', statusData['belum_kawin'] ?? 0, const Color(0xFFFF9800)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernStatCard(String title, IconData icon, Color color, String value) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF636E72),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: color,
            ),
          ),
        ],
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