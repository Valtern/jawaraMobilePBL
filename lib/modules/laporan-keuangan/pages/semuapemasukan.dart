import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/semuapemasukan_model.dart';
import '../widgets/semuapemasukan_widget.dart'; // Memastikan PemasukanCard diimpor

// =========================================================================
// A. HALAMAN DETAIL PEMASUKAN
// =========================================================================

class DetailPemasukanPage extends StatelessWidget {
  final PemasukanModel item;

  // Asumsi data verifikator adalah hardcode
  final String verifikator = 'Admin Jawara';

  const DetailPemasukanPage({super.key, required this.item});

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
                  'Detail Pemasukan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                _buildDetailRow('Nama Pemasukan', item.nama),

                _buildDetailRow('Kategori', item.jenisPemasukan),

                _buildDetailRow(
                  'Jumlah',
                  item.nominalRupiah,
                  valueColor: Colors.green.shade700,
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

// -------------------------------------------------------------------------
// B. KODE FILTER PEMASUKAN (STATEFUL)
// -------------------------------------------------------------------------

class FilterPemasukanDialog extends StatefulWidget {
  // Menghapus const dari konstruktor jika FilterDialog tidak didefinisikan secara const
  const FilterPemasukanDialog({super.key});

  @override
  State<FilterPemasukanDialog> createState() => _FilterPemasukanDialogState();
}

class _FilterPemasukanDialogState extends State<FilterPemasukanDialog> {
  // State dan Controllers
  String? _selectedKategori;
  DateTime? _dariTanggal;
  DateTime? _sampaiTanggal;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _dariTanggalController = TextEditingController();
  final TextEditingController _sampaiTanggalController =
      TextEditingController();

  final List<String> _kategoriOptions = const [
    'Iuran Warga',
    'Donasi',
    'Dana Bantuan Pemerintah',
    'Sumbangan Swadaya',
    'Hasil Usaha Kampung',
    'Pendapatan Lainnya',
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
            'Filter Pemasukan',
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
        // Tombol Reset Filter
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

        // Tombol Terapkan
        ElevatedButton(
          onPressed: () {
            // Logika Terapkan Filter
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Filter Diterapkan')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7), // Warna ungu
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

// -------------------------------------------------------------------------
// C. KODE SEMUAPEMASUKANPAGE (UTAMA)
// -------------------------------------------------------------------------

class SemuaPemasukanPage extends StatelessWidget {
  const SemuaPemasukanPage({super.key});

  // Data dummy sesuai gambar Pemasukan
  final List<PemasukanModel> _dummyData = const [
    PemasukanModel(
      no: 1,
      nama: 'Dana Bantuan RT 01',
      jenisPemasukan: 'Dana Bantuan Pemerintah',
      tanggal: '15 Okt 2025 14:23',
      nominal: 11.00, // Diubah sesuai gambar detail
    ),
    PemasukanModel(
      no: 2,
      nama: 'Iuran Warga Oktober',
      jenisPemasukan: 'Pendapatan Lainnya',
      tanggal: '13 Okt 2025 00:55',
      nominal: 4999997.00,
    ),
    PemasukanModel(
      no: 3,
      nama: 'Donasi Acara 17an',
      jenisPemasukan: 'Pendapatan Lainnya',
      tanggal: '12 Apr 2025 13:26',
      nominal: 1000000.00,
    ),
    PemasukanModel(
      no: 4,
      nama: 'Bunga Bank',
      jenisPemasukan: 'Pendapatan Lainnya',
      tanggal: '01 Jan 2025 09:00',
      nominal: 50000.00,
    ),
  ];

  // Fungsi untuk menampilkan dialog filter
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Hapus const untuk FilterPemasukanDialog jika ada masalah, tapi secara default
        // konstruktor const harus digunakan jika memungkinkan.
        return const FilterPemasukanDialog();
      },
    );
  }

  // Fungsi untuk menangani aksi Detail (Navigasi)
  void _handleCardAction(
    BuildContext context,
    String action,
    PemasukanModel item,
  ) {
    if (action == 'Detail') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPemasukanPage(item: item),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Stack untuk menempatkan tombol filter di kanan atas body.
    return Stack(
      children: [
        // Konten Utama (List Card)
        Padding(
          // PADDING ATAS 60.0 untuk menghindari tabrakan dengan tombol filter
          padding: const EdgeInsets.only(
            top: 60.0,
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          // Mengirimkan fungsi penanganan aksi ke list card
          child: SemuaPemasukanCardList(
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
