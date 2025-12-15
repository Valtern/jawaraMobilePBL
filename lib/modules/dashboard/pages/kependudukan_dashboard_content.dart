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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'Error: ${snapshot.error}',
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
                'Belum ada data kependudukan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }

        // Use _safeMap to prevent crashes
        final rootData = snapshot.data!;
        final rawKependudukan = rootData['kependudukan'];
        final data = _safeMap(rawKependudukan);
        
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

        final kawin = statusData['kawin'] ?? 0;
        final belumKawin = statusData['belum_kawin'] ?? 0;
        final totalStatus = (kawin is num ? kawin.toInt() : int.tryParse(kawin.toString()) ?? 0) +
                            (belumKawin is num ? belumKawin.toInt() : int.tryParse(belumKawin.toString()) ?? 0);
        final progressKawin = totalStatus > 0 
            ? ((kawin is num ? kawin.toInt() : int.tryParse(kawin.toString()) ?? 0) / totalStatus * 100).clamp(0.0, 100.0)
            : 0.0;
        final progressBelum = totalStatus > 0 
            ? ((belumKawin is num ? belumKawin.toInt() : int.tryParse(belumKawin.toString()) ?? 0) / totalStatus * 100).clamp(0.0, 100.0)
            : 0.0;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badge
              _buildSectionHeader('Kependudukan', 4),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              
              // Summary Cards with progress bars
              Row(
                children: [
                  Expanded(
                    child: _buildTaskCard(
                      'Total Keluarga',
                      totalKeluarga,
                      Icons.group,
                      const Color(0xFF2196F3),
                      totalKeluarga != '0' ? 70.0 : 0.0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTaskCard(
                      'Total Penduduk',
                      totalPenduduk,
                      Icons.person,
                      const Color(0xFFFF9800),
                      totalPenduduk != '0' ? 80.0 : 0.0,
                    ),
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
                        const Expanded(
                          child: Text(
                            'Jenis Kelamin',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                            overflow: TextOverflow.ellipsis,
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
                        const Expanded(
                          child: Text(
                            'Status Perkawinan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusItem('Kawin', kawin.toString(), const Color(0xFF4CAF50), progressKawin),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatusItem('Belum Kawin', belumKawin.toString(), const Color(0xFFFF9800), progressBelum),
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

  Widget _buildTaskCard(
      String label, String description, IconData icon, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
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
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
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