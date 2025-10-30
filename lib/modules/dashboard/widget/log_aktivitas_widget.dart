import 'package:flutter/material.dart';

class LogAktifitasWidget extends StatefulWidget {
  const LogAktifitasWidget({super.key});

  @override
  State<LogAktifitasWidget> createState() => _LogAktifitasWidgetState();
}

class _LogAktifitasWidgetState extends State<LogAktifitasWidget> {
  String? selectedKategori;
  String? selectedTanggal;

  final List<Map<String, String>> logData = [
    {
      'kategori': 'Keuangan',
      'tanggal': '2025-10-12',
      'deskripsi': 'Admin menambahkan data iuran bulanan warga.',
    },
    {
      'kategori': 'Kegiatan',
      'tanggal': '2025-10-13',
      'deskripsi': 'Ketua RT mengubah jadwal kerja bakti.',
    },
    {
      'kategori': 'Kependudukan',
      'tanggal': '2025-10-14',
      'deskripsi': 'User menambahkan data warga baru.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan dropdown (kalau diisi)
    final filteredLogs = logData.where((log) {
      final matchKategori =
          selectedKategori == null ||
          selectedKategori == 'Semua' ||
          log['kategori'] == selectedKategori;
      final matchTanggal =
          selectedTanggal == null ||
          selectedTanggal == 'Semua' ||
          log['tanggal'] == selectedTanggal;
      return matchKategori && matchTanggal;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Log Aktivitas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              IconButton(
                onPressed: () {
                  // bisa untuk refresh data nanti
                },
                icon: const Icon(Icons.refresh, color: Colors.deepPurple),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 🔹 Filter
          Row(
            children: [
              // Kategori filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  initialValue: selectedKategori ?? 'Semua',
                  items: ['Semua', 'Keuangan', 'Kegiatan', 'Kependudukan']
                      .map(
                        (kategori) => DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedKategori = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Tanggal filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  initialValue: selectedTanggal ?? 'Semua',
                  items: {'Semua', ...logData.map((e) => e['tanggal']!)}
                      .map(
                        (tanggal) => DropdownMenuItem(
                          value: tanggal,
                          child: Text(tanggal),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTanggal = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 List Log (Card)
          Expanded(
            child: filteredLogs.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada aktivitas ditemukan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade100,
                            child: Icon(
                              Icons.event_note,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                          title: Text(
                            log['deskripsi'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${log['kategori']} • ${log['tanggal']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
