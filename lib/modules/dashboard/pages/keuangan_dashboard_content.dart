import 'package:flutter/material.dart';

class KeuanganDashboardContent extends StatelessWidget {
  const KeuanganDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCards(),
          const SizedBox(height: 24),
          _buildCharts(),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InfoCard(
            title: 'Total Pemasukan',
            value: 'Rp 15.750.000',
            icon: Icons.arrow_downward,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: InfoCard(
            title: 'Total Pengeluaran',
            value: 'Rp 4.280.000',
            icon: Icons.arrow_upward,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: InfoCard(
            title: 'Jumlah Transaksi',
            value: '128',
            icon: Icons.swap_horiz,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildCharts() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ChartCard(
                title: 'Pemasukan per Bulan',
                child: _buildBarChart(
                  data: [8, 10, 14, 15],
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ChartCard(
                title: 'Pengeluaran per Bulan',
                child: _buildBarChart(
                  data: [5, 7, 6, 8],
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ChartCard(
                title: 'Pemasukan Berdasarkan Kategori',
                child: _buildPieChart(
                  data: [
                    {'value': 40.0, 'color': Colors.blue},
                    {'value': 30.0, 'color': Colors.yellow},
                    {'value': 15.0, 'color': Colors.pink},
                    {'value': 15.0, 'color': Colors.green},
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ChartCard(
                title: 'Pengeluaran Berdasarkan Kategori',
                child: _buildPieChart(
                  data: [
                    {'value': 25.0, 'color': Colors.purple},
                    {'value': 25.0, 'color': Colors.orange},
                    {'value': 20.0, 'color': Colors.red},
                    {'value': 30.0, 'color': Colors.teal},
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarChart({required List<double> data, required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((value) {
        return Flexible(
          child: FractionallySizedBox(
            heightFactor: value / 20,
            child: Container(color: color),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChart({required List<Map<String, dynamic>> data}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: data.map((entry) {
            return Flexible(
              flex: (entry['value'] as double).toInt(),
              child: Container(height: 20, color: entry['color'] as Color),
            );
          }).toList(),
        );
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: TextStyle(color: color)),
              ),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ChartCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
