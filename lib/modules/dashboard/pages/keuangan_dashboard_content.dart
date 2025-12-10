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
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
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
    final theme = Theme.of(context);
    final pemasukanColor = theme.colorScheme.primary;
    final pengeluaranColor = theme.colorScheme.error;

    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Gagal memuat data: ${snapshot.error}"));
        }

        final data = snapshot.data?['keuangan'] ?? {};
        
        // Safe access to totals
        final totalMasuk = data['total_pemasukan'] ?? 0;
        final totalKeluar = data['total_pengeluaran'] ?? 0;

        // SAFE PARSING LOGIC APPLIED HERE
        final chartMasuk = _parseChartData(data['chart_pemasukan'] as List?);
        final chartKeluar = _parseChartData(data['chart_pengeluaran'] as List?);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Pemasukan',
                      formatRupiah(totalMasuk),
                      Icons.arrow_downward,
                      pemasukanColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      'Pengeluaran',
                      formatRupiah(totalKeluar),
                      Icons.arrow_upward,
                      pengeluaranColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Keuangan Tahun Ini',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles:
                                  SideTitles(showTitles: false),
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
                                    'Dec'
                                  ];
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < 12) {
                                    return Text(
                                      months[value.toInt()],
                                      style:
                                          const TextStyle(fontSize: 10),
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
                                  color: pemasukanColor,
                                  width: 6,
                                ),
                                BarChartRodData(
                                  toY: chartKeluar[index],
                                  color: pengeluaranColor,
                                  width: 6,
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

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.16),
            color.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1B33),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}