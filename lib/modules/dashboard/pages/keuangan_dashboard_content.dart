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

        final total = (totalMasuk is num ? totalMasuk.toDouble() : double.tryParse(totalMasuk.toString()) ?? 0) +
                      (totalKeluar is num ? totalKeluar.toDouble() : double.tryParse(totalKeluar.toString()) ?? 0);
        final saldo = (totalMasuk is num ? totalMasuk.toDouble() : double.tryParse(totalMasuk.toString()) ?? 0) -
                     (totalKeluar is num ? totalKeluar.toDouble() : double.tryParse(totalKeluar.toString()) ?? 0);
        final progressMasuk = total > 0 
            ? ((totalMasuk is num ? totalMasuk.toDouble() : double.tryParse(totalMasuk.toString()) ?? 0) / total * 100).clamp(0.0, 100.0)
            : 0.0;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards with Modern Design
              Row(
                children: [
                  Expanded(
                    child: _buildModernInfoCard(
                      'Pemasukan',
                      formatRupiah(totalMasuk),
                      Icons.arrow_downward,
                      const Color(0xFF4CAF50),
                      progressMasuk,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernInfoCard(
                      'Pengeluaran',
                      formatRupiah(totalKeluar),
                      Icons.arrow_upward,
                      const Color(0xFFF44336),
                      100 - progressMasuk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Saldo Card
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
                      'Saldo',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF636E72),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        formatRupiah(saldo),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
                            leftTitles:
                                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles:
                                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles:
                                AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                  ];
                                  if (value.toInt() >= 0 && value.toInt() < 12) {
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
                                    color: const Color(0xFF4CAF50),
                                    width: 8,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                                BarChartRodData(
                                    toY: chartKeluar[index],
                                    color: const Color(0xFFF44336),
                                    width: 8,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
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

  Widget _buildModernInfoCard(
      String title, String value, IconData icon, Color color, double progress) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                '${progress.toInt()}%',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
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
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
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
}