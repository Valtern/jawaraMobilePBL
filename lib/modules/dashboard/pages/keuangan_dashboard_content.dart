import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:jawarapbl/services/dashboard_service.dart';

class KeuanganDashboardContent extends StatefulWidget {
  const KeuanganDashboardContent({super.key});

  @override
  State<KeuanganDashboardContent> createState() =>
      _KeuanganDashboardContentState();
}

class _KeuanganDashboardContentState extends State<KeuanganDashboardContent> {
  final DashboardService _service = DashboardService();
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _service.getDashboardStats();
  }

  String formatRupiah(dynamic value) {
    double numValue = 0;
    if (value is String) {
      numValue = double.tryParse(value) ?? 0;
    } else if (value is num) {
      numValue = value.toDouble();
    }

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(numValue);
  }

  // Helper to safely convert API list data to List<double>
  List<double> _parseChartData(List<dynamic>? data) {
    if (data == null) return List.filled(12, 0.0);
    return data.map((e) {
      if (e is String) {
        return double.tryParse(e) ?? 0.0;
      } else if (e is num) {
        return e.toDouble();
      }
      return 0.0;
    }).toList();
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
                'Belum ada data keuangan',
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
        final data = rootData['keuangan'] ?? {};

        // Safe access to totals
        final totalMasuk = data['total_pemasukan'] ?? 0;
        final totalKeluar = data['total_pengeluaran'] ?? 0;

        // SAFE PARSING LOGIC APPLIED HERE
        final chartMasuk = _parseChartData(data['chart_pemasukan'] as List?);
        final chartKeluar = _parseChartData(data['chart_pengeluaran'] as List?);

        // Calculate totals for progress
        final total =
            (totalMasuk is num
                ? totalMasuk.toDouble()
                : double.tryParse(totalMasuk.toString()) ?? 0) +
            (totalKeluar is num
                ? totalKeluar.toDouble()
                : double.tryParse(totalKeluar.toString()) ?? 0);
        final progressMasuk = total > 0
            ? ((totalMasuk is num
                          ? totalMasuk.toDouble()
                          : double.tryParse(totalMasuk.toString()) ?? 0) /
                      total *
                      100)
                  .clamp(0.0, 100.0)
            : 0.0;
        final progressKeluar = total > 0
            ? ((totalKeluar is num
                          ? totalKeluar.toDouble()
                          : double.tryParse(totalKeluar.toString()) ?? 0) /
                      total *
                      100)
                  .clamp(0.0, 100.0)
            : 0.0;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badge
              _buildSectionHeader('Keuangan', 2),
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

              // Summary Cards with progress bars
              Row(
                children: [
                  Expanded(
                    child: _buildTaskCard(
                      'Pemasukan',
                      formatRupiah(totalMasuk),
                      Icons.arrow_downward,
                      const Color(0xFF2196F3),
                      progressMasuk,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTaskCard(
                      'Pengeluaran',
                      formatRupiah(totalKeluar),
                      Icons.arrow_upward,
                      const Color(0xFFFF9800),
                      progressKeluar,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Charts Card
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
                    const Text(
                      "Grafik Keuangan Tahun Ini",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'May',
                                    'Jun',
                                    'Jul',
                                    'Aug',
                                    'Sep',
                                    'Oct',
                                    'Nov',
                                    'Dec',
                                  ];
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < 12) {
                                    return Text(
                                      months[value.toInt()],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Poppins',
                                        color: Color(0xFF636E72),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(12, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: chartMasuk[index],
                                  color: const Color(0xFF2196F3),
                                  width: 8,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                                BarChartRodData(
                                  toY: chartKeluar[index],
                                  color: const Color(0xFFFF9800),
                                  width: 8,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
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
    String label,
    String description,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
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
              fontSize: 16,
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
}
