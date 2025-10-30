import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/dashboard/widget/kegiatan_widget.dart';

class KegiatanDashboardContent extends StatelessWidget {
  const KegiatanDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
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
              _buildTotalKegiatanCard(),
              _buildKegiatanPerKategoriCard(),
              _buildKegiatanByWaktuCard(),
              _buildPenanggungJawabCard(),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 250, child: _buildKegiatanPerBulanCard()),
        ],
      ),
    );
  }

  Widget _buildTotalKegiatanCard() {
    return DashboardCard(
      title: 'Total Kegiatan',
      icon: Icons.event_note,
      color: Colors.blue.shade700,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '25',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text(
            'Jumlah seluruh event yang sudah ada',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildKegiatanPerKategoriCard() {
    return DashboardCard(
      title: 'Kegiatan per Kategori',
      icon: Icons.category,
      color: Colors.green.shade700,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKategoriRow(Colors.blue, 'Rapat Warga: 8'),
          const SizedBox(height: 4),
          _buildKategoriRow(Colors.orange, 'Kerja Bakti: 5'),
          const SizedBox(height: 4),
          _buildKategoriRow(Colors.red, 'Perlombaan: 7'),
          const SizedBox(height: 4),
          _buildKategoriRow(Colors.purple, 'Lainnya: 5'),
        ],
      ),
    );
  }

  Widget _buildKategoriRow(Color color, String text) {
    return Row(
      children: [
        Container(width: 15, height: 15, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildKegiatanByWaktuCard() {
    return DashboardCard(
      title: 'Kegiatan berdasarkan Waktu',
      icon: Icons.schedule,
      color: Colors.amber.shade800,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Sudah Lewat: 15'),
          SizedBox(height: 4),
          Text('Hari Ini: 2'),
          SizedBox(height: 4),
          Text('Akan Datang: 8'),
        ],
      ),
    );
  }

  Widget _buildPenanggungJawabCard() {
    return DashboardCard(
      title: 'Penanggung Jawab Terbanyak',
      icon: Icons.person,
      color: Colors.purple.shade700,
      child: const Center(child: Text('Budi', style: TextStyle(fontSize: 24))),
    );
  }

  Widget _buildKegiatanPerBulanCard() {
    return DashboardCard(
      title: 'Kegiatan per Bulan (Tahun Ini)',
      icon: Icons.calendar_today,
      color: Colors.pink.shade700,
      child: Container(
        alignment: Alignment.center,
        child: const Text(
          'Chart will be displayed here',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
