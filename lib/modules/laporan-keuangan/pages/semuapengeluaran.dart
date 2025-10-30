import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Diperlukan untuk format tanggal dan showDatePicker
import '../models/semuapengeluaran_model.dart';
import '../widgets/semuapengeluaran_widget.dart'; // Menggunakan widget card list

// =========================================================================
// A. HALAMAN BARU: DETAIL PENGELUARAN
// =========================================================================

class DetailPengeluaranPage extends StatelessWidget {
  final PengeluaranModel item;

  // Asumsi data verifikator adalah hardcode
  final String verifikator = 'Admin Jawara';

  const DetailPengeluaranPage({super.key, required this.item});

  // Helper untuk baris detail
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

                _buildDetailRow('Kategori', item.jenisPengeluaran),

                _buildDetailRow(
                  'Jumlah',
                  item.nominalRupiah,
                  valueColor: Colors.red.shade700, // Merah untuk pengeluaran
                ),

                _buildDetailRow('Verifikator', verifikator),
                _buildDetailRow('Tanggal Transaksi', item.tanggal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// B. KODE FILTER PENGELUARAN (STATEFUL)
// =========================================================================

class FilterPengeluaranDialog extends StatefulWidget {
  const FilterPengeluaranDialog({super.key});

  @override
  State<FilterPengeluaranDialog> createState() =>
      _FilterPengeluaranDialogState();
}

class _FilterPengeluaranDialogState extends State<FilterPengeluaranDialog> {
  // State dan Controllers
  String? _selectedKategori;
  DateTime? _dariTanggal;
  DateTime? _sampaiTanggal;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _dariTanggalController = TextEditingController();
  final TextEditingController _sampaiTanggalController =
      TextEditingController();

  final List<String> _kategoriOptions = const [
    'Operasional RT/RW',
    'Kegiatan Sosial',
    'Pemeliharaan Fasilitas',
    'Pembangunan',
    'Kegiatan Warga',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _dariTanggalController.dispose();
    _sampaiTanggalController.dispose();
    super.dispose();
  }

  // --- Logika Tanggal ---
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    bool isStartDate,
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
        if (isStartDate) {
          _dariTanggal = picked;
        } else {
          _sampaiTanggal = picked;
        }
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // --- Logika Reset ---
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

  // --- Widget Row Input Tanggal ---
  Widget _buildDateInput(
    String label,
    TextEditingController controller,
    DateTime? dateValue,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        if (isStartDate) {
                          _dariTanggal = null;
                        } else {
                          _sampaiTanggal = null;
                        }
                        controller.clear();
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20),
                  onPressed: () =>
                      _selectDate(context, controller, isStartDate),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
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
            // 1. Nama
            const Text('Nama'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                hintText: 'Cari nama...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Kategori
            const Text('Kategori'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedKategori,
              decoration: const InputDecoration(
                hintText: '-- Pilih Kategori --',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: _kategoriOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedKategori = newValue;
                });
              },
            ),
            const SizedBox(height: 24),

            // 3. Dari Tanggal
            _buildDateInput(
              'Dari Tanggal',
              _dariTanggalController,
              _dariTanggal,
              true,
            ),

            // 4. Sampai Tanggal
            _buildDateInput(
              'Sampai Tanggal',
              _sampaiTanggalController,
              _sampaiTanggal,
              false,
            ),
          ],
        ),
      ),
      // --- Tombol Aksi ---
      actions: <Widget>[
        OutlinedButton(
          onPressed: _resetFilter,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundColor: Colors.black54,
            backgroundColor: Colors.grey[50],
          ),
          child: const Text('Reset Filter'),
        ),
        ElevatedButton(
          onPressed: () {
            // Logika Terapkan Filter
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Filter Diterapkan')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Terapkan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// =========================================================================
// C. KODE SEMUAPENGELUARANPAGE (UTAMA)
// =========================================================================

class SemuaPengeluaranPage extends StatelessWidget {
  const SemuaPengeluaranPage({super.key});

  // Data dummy sesuai gambar Pengeluaran
  final List<PengeluaranModel> _dummyData = const [
    PengeluaranModel(
      no: 1,
      nama: 'Kerja Bakti', // Diubah sesuai gambar detail
      jenisPengeluaran: 'Pemeliharaan Fasilitas',
      tanggal: '19 Oct 2025 20:26',
      nominal: 50000.00, // Diubah sesuai gambar detail
    ),
    PengeluaranModel(
      no: 2,
      nama: 'Snack Rapat Warga',
      jenisPengeluaran: 'Kegiatan Warga',
      tanggal: '19 Oct 2025 20:26',
      nominal: 100000.00,
    ),
    PengeluaranModel(
      no: 3,
      nama: 'Bayar Listrik Pos Jaga',
      jenisPengeluaran: 'Operasional RT/RW',
      tanggal: '17 Oct 2025 02:30',
      nominal: 75000.00,
    ),
    PengeluaranModel(
      no: 4,
      nama: 'Perbaikan Pagar Sekolah',
      jenisPengeluaran: 'Pemeliharaan Fasilitas',
      tanggal: '10 Oct 2025 01:08',
      nominal: 2112000.00,
    ),
  ];

  // Fungsi untuk menampilkan dialog filter
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const FilterPengeluaranDialog();
      },
    );
  }

  // Fungsi untuk menangani aksi Detail (Navigasi)
  void _handleCardAction(
    BuildContext context,
    String action,
    PengeluaranModel item,
  ) {
    if (action == 'Detail') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPengeluaranPage(item: item),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengganti FloatingActionButton dengan tombol filter di kanan atas (menggunakan Stack)
    return Stack(
      children: [
        // Konten Utama (List Card)
        Padding(
          // PADDING DIKOREKSI: Memberi ruang di atas untuk tombol filter
          padding: const EdgeInsets.only(
            top: 60.0,
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          // MENGIRIMKAN FUNGSI PENANGANAN AKSI KE LIST CARD
          child: SemuaPengeluaranCardList(
            data: _dummyData,
            onCardAction: (action, item) =>
                _handleCardAction(context, action, item),
          ),
        ),

        // Tombol Filter di kanan atas (posisi Absolute)
        Positioned(
          top: 16, // Jarak dari atas TabBarView
          right: 16, // Jarak dari kanan
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
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
    );
  }
}
