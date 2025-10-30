import 'package:flutter/material.dart';

class MutasiKeluargaWidget extends StatefulWidget {
  const MutasiKeluargaWidget({super.key});

  @override
  State<MutasiKeluargaWidget> createState() => _MutasiKeluargaWidgetState();
}

class _MutasiKeluargaWidgetState extends State<MutasiKeluargaWidget> {
  // 🔹 Data contoh mutasi keluarga
  final List<Map<String, String>> mutasiList = [
    {
      'nama': 'Keluarga Andi',
      'jenis': 'Pindah Domisili',
      'tanggal': '10 Oktober 2025',
      'keterangan': 'Pindah ke Surabaya',
    },
    {
      'nama': 'Keluarga Budi',
      'jenis': 'Kelahiran Anggota Baru',
      'tanggal': '8 Oktober 2025',
      'keterangan': 'Anak pertama lahir',
    },
  ];

  // 🔹 Form input controller
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  String? selectedJenis;

  // 🔹 Jenis mutasi (dropdown)
  final List<String> jenisMutasiList = [
    'Pindah Domisili',
    'Kelahiran Anggota Baru',
    'Kematian Anggota',
    'Perubahan Status',
  ];

  // 🔹 Menambah data baru
  void _tambahMutasi() {
    if (_namaController.text.isNotEmpty &&
        selectedJenis != null &&
        _keteranganController.text.isNotEmpty) {
      setState(() {
        mutasiList.add({
          'nama': _namaController.text,
          'jenis': selectedJenis!,
          'tanggal': DateTime.now().toString().substring(0, 10),
          'keterangan': _keteranganController.text,
        });
      });

      _namaController.clear();
      _keteranganController.clear();
      selectedJenis = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mutasi keluarga berhasil ditambahkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            const Text(
              "Pendaftaran Mutasi Keluarga",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Form Tambah Mutasi
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Keluarga",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedJenis,
                      items: jenisMutasiList
                          .map(
                            (jenis) => DropdownMenuItem(
                              value: jenis,
                              child: Text(jenis),
                            ),
                          )
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: "Jenis Mutasi",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          selectedJenis = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _keteranganController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Keterangan",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        onPressed: _tambahMutasi,
                        label: const Text("Tambah Mutasi"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🔹 Dropdown daftar mutasi
            const Text(
              "Daftar Mutasi Keluarga",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.deepPurple.shade50,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text("Pilih Mutasi Keluarga"),
                  items: mutasiList.map((mutasi) {
                    return DropdownMenuItem(
                      value: mutasi['nama'],
                      child: Text(mutasi['nama']!),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Tabel mutasi keluarga
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Jenis')),
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Keterangan')),
                ],
                rows: mutasiList.map((mutasi) {
                  return DataRow(
                    cells: [
                      DataCell(Text(mutasi['nama']!)),
                      DataCell(Text(mutasi['jenis']!)),
                      DataCell(Text(mutasi['tanggal']!)),
                      DataCell(Text(mutasi['keterangan']!)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
