import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/log-aktivitas/widgets/log_aktivitas_card.dart';

class LogAktivitasPage extends StatelessWidget {
  const LogAktivitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> aktivitasList = [
      {
        'deskripsi': 'Menambahkan transfer channel baru: Bank Mega',
        'aktor': 'Admin Jawara',
        'tanggal': '15 Oktober 2025',
      },
      {
        'deskripsi': 'Memperbarui transfer channel: 234234',
        'aktor': 'Admin Jawara',
        'tanggal': '15 Oktober 2025',
      },
      {
        'deskripsi': 'Mendownload laporan keuangan',
        'aktor': 'Admin Jawara',
        'tanggal': '14 Oktober 2025',
      },
      {
        'deskripsi': 'Mengubah iuran: Agustusan',
        'aktor': 'Admin Jawara',
        'tanggal': '14 Oktober 2025',
      },
      {
        'deskripsi': 'Menambah data warga baru: Budi Santoso',
        'aktor': 'Admin Jawara',
        'tanggal': '13 Oktober 2025',
      },
      {
        'deskripsi': 'Menghapus data iuran lama',
        'aktor': 'Admin Jawara',
        'tanggal': '12 Oktober 2025',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Log Aktivitas'),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        titleTextStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header dan filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Log Aktivitas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: tambahkan filter logika di sini
                  },
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text("Filter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Daftar aktivitas dalam bentuk card
            Expanded(
              child: ListView.separated(
                itemCount: aktivitasList.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = aktivitasList[index];
                  return LogAktivitasCard(
                    deskripsi: item['deskripsi']!,
                    aktor: item['aktor']!,
                    tanggal: item['tanggal']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
