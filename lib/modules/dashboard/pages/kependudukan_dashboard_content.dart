import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/dashboard/widget/kependudukan_card.dart';

class KependudukanDashboardContent extends StatelessWidget {
  const KependudukanDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16.0),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.75,
      children: [
        _buildTotalKeluargaCard(),
        _buildTotalPendudukCard(),
        _buildStatusPendudukCard(),
        _buildJenisKelaminCard(),
        _buildPekerjaanPendudukCard(),
        _buildPeranKeluargaCard(),
        _buildAgamaCard(),
        _buildPendidikanCard(),
      ],
    );
  }

  Widget _buildTotalKeluargaCard() {
    return KependudukanCard(
      title: 'Total Keluarga',
      icon: Icons.group,
      color: Colors.blue.shade700,
      child: const Center(
        child: Text(
          '58',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTotalPendudukCard() {
    return KependudukanCard(
      title: 'Total Penduduk',
      icon: Icons.person,
      color: Colors.green.shade600,
      child: const Center(
        child: Text(
          '172',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatusPendudukCard() {
    return KependudukanCard(
      title: 'Status Penduduk',
      icon: Icons.toggle_on,
      color: Colors.amber.shade800,
      height: 200,
      child: _buildPieChartPlaceholder(
        chartColor: Colors.green,
        label: 'Aktif 95%',
        value: 0.95,
      ),
    );
  }

  Widget _buildJenisKelaminCard() {
    return KependudukanCard(
      title: 'Jenis Kelamin',
      icon: Icons.wc,
      color: Colors.purple.shade600,
      height: 200,
      child: _buildPieChartPlaceholder(
        chartColor: Colors.blue,
        label: 'Laki-laki 55%',
        value: 0.55,
      ),
    );
  }

  Widget _buildPekerjaanPendudukCard() {
    return KependudukanCard(
      title: 'Pekerjaan Penduduk',
      icon: Icons.work,
      color: Colors.pink.shade600,
      child: const Center(
        child: Text('Wiraswasta', style: TextStyle(fontSize: 24)),
      ),
    );
  }

  Widget _buildPeranKeluargaCard() {
    return KependudukanCard(
      title: 'Peran dalam Keluarga',
      icon: Icons.family_restroom,
      color: Colors.orange.shade700,
      height: 200,
      child: _buildPieChartPlaceholder(
        chartColor: Colors.blue,
        label: 'Kepala Keluarga 33%',
        value: 0.33,
      ),
    );
  }

  Widget _buildAgamaCard() {
    return KependudukanCard(
      title: 'Agama',
      icon: Icons.mosque,
      color: Colors.red.shade700,
      child: const Center(child: Text('Islam', style: TextStyle(fontSize: 24))),
    );
  }

  Widget _buildPendidikanCard() {
    return KependudukanCard(
      title: 'Pendidikan',
      icon: Icons.school,
      color: Colors.teal.shade600,
      child: const Center(child: Text('SMA', style: TextStyle(fontSize: 24))),
    );
  }

  Widget _buildPieChartPlaceholder({
    required Color chartColor,
    required String label,
    required double value,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 15,
                backgroundColor: chartColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(chartColor),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 12, height: 12, color: chartColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
