import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/widgets/mutasi_card.dart';

class DaftarMutasiContent extends StatelessWidget {
  const DaftarMutasiContent({super.key});

  // Dummy data for the list
  final List<MutasiData> mutasiList = const [
    MutasiData(
      nama: 'Budi Santoso',
      tanggal: '12 Oktober 2025',
      jenis: 'Pindah Datang',
    ),
    MutasiData(
      nama: 'Keluarga Andi',
      tanggal: '10 Oktober 2025',
      jenis: 'Pindah Keluar',
    ),
    MutasiData(
      nama: 'Siti Aminah',
      tanggal: '08 Oktober 2025',
      jenis: 'Kematian',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul halaman
          const Text(
            'Daftar Mutasi Keluarga',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 20),

          // Daftar card-based list
          Expanded(
            child: ListView.separated(
              itemCount: mutasiList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = mutasiList[index];
                return MutasiCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}
