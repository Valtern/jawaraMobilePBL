import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Widget untuk Form Cetak Laporan Keuangan (sesuai gambar)
class CetakLaporanForm extends StatefulWidget {
  const CetakLaporanForm({super.key});

  @override
  State<CetakLaporanForm> createState() => _CetakLaporanFormState();
}

class _CetakLaporanFormState extends State<CetakLaporanForm> {
  DateTime? _tanggalMulai;
  DateTime? _tanggalAkhir;
  String _jenisLaporan = 'Semua';
  final List<String> _jenisOptions = ['Semua', 'Pemasukan', 'Pengeluaran'];
  final TextEditingController _controllerMulai = TextEditingController();
  final TextEditingController _controllerAkhir = TextEditingController();

  // Memilih tanggal
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'), // Opsional: Tambahkan locale Indonesia
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _tanggalMulai = picked;
          // Menggunakan format yang sesuai dengan gambar/kebutuhan
          _controllerMulai.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _tanggalAkhir = picked;
          _controllerAkhir.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  // Mengatur ulang filter
  void _resetFilter() {
    setState(() {
      _tanggalMulai = null;
      _tanggalAkhir = null;
      _jenisLaporan = 'Semua';
      _controllerMulai.clear();
      _controllerAkhir.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Filter telah direset')));
  }

  // Fungsi untuk memicu download PDF (placeholder)
  void _downloadPdf() {
    String tglMulai = _tanggalMulai != null
        ? DateFormat('dd MMMM yyyy').format(_tanggalMulai!)
        : 'Awal Data';
    String tglAkhir = _tanggalAkhir != null
        ? DateFormat('dd MMMM yyyy').format(_tanggalAkhir!)
        : 'Akhir Data';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mempersiapkan PDF Laporan: $_jenisLaporan (dari $tglMulai sampai $tglAkhir)',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _controllerMulai.dispose();
    _controllerAkhir.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // KOREKSI ERROR: Mengubah MainMinSize menjadi MainAxisSize.min
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Cetak Laporan Keuangan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Baris Tanggal Mulai dan Akhir
          Row(
            children: [
              // Tanggal Mulai
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal Mulai',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controllerMulai,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '--/--/----',
                        border: const OutlineInputBorder(),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_tanggalMulai != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                ), // Ikon 'x'
                                onPressed: () {
                                  setState(() {
                                    _tanggalMulai = null;
                                    _controllerMulai.clear();
                                  });
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today, size: 20),
                              onPressed: () => _selectDate(context, true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Tanggal Akhir
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal Akhir',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controllerAkhir,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '--/--/----',
                        border: const OutlineInputBorder(),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_tanggalAkhir != null)
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                ), // Ikon 'x'
                                onPressed: () {
                                  setState(() {
                                    _tanggalAkhir = null;
                                    _controllerAkhir.clear();
                                  });
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today, size: 20),
                              onPressed: () => _selectDate(context, false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Jenis Laporan
          const Text(
            'Jenis Laporan',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _jenisLaporan,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
            items: _jenisOptions.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _jenisLaporan = newValue!;
              });
            },
          ),
          const SizedBox(height: 30),

          // Tombol Aksi
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _downloadPdf,
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Download PDF',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Tombol Reset
              OutlinedButton(
                onPressed: _resetFilter,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
