import 'package:flutter/material.dart';

class DaftarMutasiContent extends StatelessWidget {
  const DaftarMutasiContent({super.key});

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

          // Tabel data dalam card full width
          Expanded(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // scroll ke samping
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Colors.deepPurple.shade50,
                      ),
                      dataRowColor: WidgetStateProperty.all(
                        Colors.grey.shade50,
                      ),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      dataTextStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      columnSpacing: 50,
                      horizontalMargin: 24,
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Nama Kepala Keluarga')),
                        DataColumn(label: Text('Tanggal Mutasi')),
                        DataColumn(label: Text('Jenis Mutasi')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: [
                        DataRow(
                          cells: [
                            const DataCell(Text('1')),
                            const DataCell(Text('Budi Santoso')),
                            const DataCell(Text('12 Oktober 2025')),
                            const DataCell(Text('Pindah Datang')),
                            DataCell(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.black,
                                    ),
                                    tooltip: 'Lihat Detail',
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
