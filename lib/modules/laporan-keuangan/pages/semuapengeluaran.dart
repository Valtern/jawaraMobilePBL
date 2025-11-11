// lib/modules/laporan-keuangan/pages/semuapengeluaran.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawarapbl/services/pengeluaran_service.dart'; // FIXED
import 'package:jawarapbl/shared/models/pengeluaran_model.dart'; // FIXED

// =========================================================================
// A. HALAMAN DETAIL PENGELUARAN
// =========================================================================

class DetailPengeluaranPage extends StatelessWidget {
  final Pengeluaran item; // FIXED: Use shared Pengeluaran model
  final String verifikator = 'Admin Jawara';

  const DetailPengeluaranPage({super.key, required this.item});

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Use intl to format nominal value
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kembali',
          style: TextStyle(fontSize: 16, color: Colors.deepPurple),
        ),
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pengeluaran',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                _buildDetailRow('Nama Pengeluaran', item.nama),
                _buildDetailRow('Kategori', item.kategori),
                _buildDetailRow(
                  'Jumlah',
                  formatCurrency.format(item.nominal), // FIXED: Use item.nominal
                  valueColor: Colors.red.shade700,
                ),
                _buildDetailRow('Verifikator', verifikator),
                _buildDetailRow(
                  'Tanggal Transaksi', 
                  DateFormat('dd MMMM yyyy', 'id_ID').format(item.tanggal) // FIXED: Format DateTime
                ),
                _buildDetailRow('Deskripsi', item.deskripsi ?? '-'), // FIXED: Handle null
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// B. KODE FILTER PENGELUARAN (Unchanged)
// -------------------------------------------------------------------------

class FilterPengeluaranDialog extends StatefulWidget {
  const FilterPengeluaranDialog({super.key});

  @override
  State<FilterPengeluaranDialog> createState() =>
      _FilterPengeluaranDialogState();
}

class _FilterPengeluaranDialogState extends State<FilterPengeluaranDialog> {
  String? _selectedKategori;
  DateTime? _dariTanggal;
  DateTime? _sampaiTanggal;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _dariTanggalController = TextEditingController();
  final TextEditingController _sampaiTanggalController =
      TextEditingController();

  final List<String> _kategoriOptions = const [
    'Makan',
    'Perbaikan',
    'Kegiatan',
    'Operasional',
    'Lainnya',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _dariTanggalController.dispose();
    _sampaiTanggalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    bool isStart,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _dariTanggal = picked;
        } else {
          _sampaiTanggal = picked;
        }
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _selectedKategori = null;
      _dariTanggal = null;
      _sampaiTanggal = null;
      _namaController.clear();
      _dariTanggalController.clear();
      _sampaiTanggalController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filter Pengeluaran',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nama'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                hintText: 'Cari nama...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Kategori'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedKategori,
              decoration: const InputDecoration(
                hintText: '-- Pilih Kategori --',
                border: OutlineInputBorder(),
              ),
              items: _kategoriOptions
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (newValue) => setState(() {
                _selectedKategori = newValue;
              }),
            ),
            const SizedBox(height: 24),
            _buildDateInput('Dari Tanggal', _dariTanggalController, true),
            _buildDateInput('Sampai Tanggal', _sampaiTanggalController, false),
          ],
        ),
      ),
      actions: <Widget>[
        OutlinedButton(
          onPressed: _resetFilter,
          child: const Text('Reset Filter'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Filter diterapkan')));
          },
          child: const Text('Terapkan'),
        ),
      ],
    );
  }

  Widget _buildDateInput(
    String label,
    TextEditingController controller,
    bool isStartDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: '--/--/----',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context, controller, isStartDate),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// -------------------------------------------------------------------------
// C. HALAMAN SEMUA PENGELUARAN TANPA EDIT/DELETE
// -------------------------------------------------------------------------

class SemuaPengeluaranPage extends StatefulWidget {
  const SemuaPengeluaranPage({super.key});

  @override
  State<SemuaPengeluaranPage> createState() => _SemuaPengeluaranPageState();
}

class _SemuaPengeluaranPageState extends State<SemuaPengeluaranPage> {
  late Future<List<Pengeluaran>> _futureData; // FIXED: Use shared Pengeluaran model
  final PengeluaranService _pengeluaranService = PengeluaranService(); // FIXED

  @override
  void initState() {
    super.initState();
    _futureData = _fetchPengeluaran();
  }

  // FIXED: Fetch data using PengeluaranService
  Future<List<Pengeluaran>> _fetchPengeluaran() async {
    try {
      // Pass an empty map for filters as required by the service
      return await _pengeluaranService.getPengeluaran({});
    } catch (e) {
      // Throw exception to be caught by FutureBuilder
      throw Exception('Gagal memuat data pengeluaran: $e');
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FilterPengeluaranDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 60,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: FutureBuilder<List<Pengeluaran>>( // FIXED: Use Pengeluaran
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data pengeluaran.'),
                  );
                }

                final data = snapshot.data!;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          item.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // FIXED: Use shared model properties and format DateTime
                        subtitle: Text(
                          '${item.kategori} • ${DateFormat('dd/MM/yyyy').format(item.tanggal)}'
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailPengeluaranPage(item: item),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => _showFilterDialog(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}