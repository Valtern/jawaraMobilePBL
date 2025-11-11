import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/semuapemasukan_model.dart';
import 'package:jawarapbl/services/pemasukan_laporan_service.dart';

class DetailPemasukanPage extends StatelessWidget {
  final PemasukanModel item;
  final String verifikator = 'Admin Jawara';

  const DetailPemasukanPage({super.key, required this.item});

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

class SemuaPemasukanPage extends StatefulWidget {
  const SemuaPemasukanPage({super.key});

  @override
  State<SemuaPemasukanPage> createState() => _SemuaPemasukanPageState();
}

class _SemuaPemasukanPageState extends State<SemuaPemasukanPage> {
  late Future<List<PemasukanModel>> _futureData;
  final PemasukanLaporanService _pemasukanService = PemasukanLaporanService();
  
  List<PemasukanModel> _allPemasukan = [];
  Map<String, String> _currentFilters = {};
  List<PemasukanModel> _filteredPemasukan = [];

  @override
  void initState() {
    super.initState();
    _futureData = _fetchPemasukan();
  }

  Future<List<PemasukanModel>> _fetchPemasukan() async {
    try {
      final data = await _pemasukanService.getLaporanPemasukan();
      _allPemasukan = data;
      _applyFilters();
      return _filteredPemasukan;
    } catch (e) {
      rethrow;
    }
  }

  void _applyFilters() {
    _filteredPemasukan = _allPemasukan.where((item) {
      // Filter by Nama
      if (_currentFilters['nama'] != null && _currentFilters['nama']!.isNotEmpty) {
        if (!item.nama.toLowerCase().contains(_currentFilters['nama']!.toLowerCase())) {
          return false;
        }
      }
      // Filter by Kategori
      if (_currentFilters['kategori'] != null && _currentFilters['kategori'] != 'Semua Kategori') {
        if (item.jenisPemasukan != _currentFilters['kategori']) {
          return false;
        }
      }
      // Filter by Tanggal Mulai
      if (_currentFilters['tanggal_mulai'] != null) {
        final tglMulai = DateFormat('dd/MM/yyyy').parse(_currentFilters['tanggal_mulai']!);
        if (item.tanggalSort.isBefore(tglMulai)) {
          return false;
        }
      }
      // Filter by Tanggal Akhir
      if (_currentFilters['tanggal_akhir'] != null) {
        final tglAkhir = DateFormat('dd/MM/yyyy').parse(_currentFilters['tanggal_akhir']!);
        if (item.tanggalSort.isAfter(tglAkhir.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, // FIXED: Set background to white
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // FIXED: FLAT TOP
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _PemasukanFilterSheet(
            initialFilters: _currentFilters,
            onFilterApplied: (filters) {
              setState(() {
                _currentFilters = filters;
                _applyFilters();
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, PemasukanModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPemasukanPage(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 60.0,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: FutureBuilder<List<PemasukanModel>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  String errorMessage = snapshot.error.toString().replaceAll('Exception: ', '');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
                          const SizedBox(height: 16),
                          const Text(
                            'Gagal Memuat Data',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage,
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (_allPemasukan.isEmpty) {
                  return const Center(child: Text('Tidak ada data pemasukan.'));
                }

                if (_filteredPemasukan.isEmpty) {
                  return const Center(child: Text('Tidak ada data yang cocok dengan filter.'));
                }

                return ListView.builder(
                  itemCount: _filteredPemasukan.length,
                  itemBuilder: (context, index) {
                    final item = _filteredPemasukan[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
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
                        subtitle: Text(
                          '${item.jenisPemasukan} • ${item.tanggal}',
                        ),
                        trailing: Text(
                          item.nominalRupiah,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _openDetail(context, item),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => _showFilterBottomSheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PemasukanFilterSheet extends StatefulWidget {
  final Map<String, String> initialFilters;
  final Function(Map<String, String>) onFilterApplied;

  const _PemasukanFilterSheet({
    required this.initialFilters,
    required this.onFilterApplied,
  });

  @override
  State<_PemasukanFilterSheet> createState() =>
      _PemasukanFilterSheetState();
}

class _PemasukanFilterSheetState
    extends State<_PemasukanFilterSheet> {
  String? _selectedKategori;
  DateTime? _dariTanggal;
  DateTime? _sampaiTanggal;
  late TextEditingController _namaController;
  late TextEditingController _dariTanggalController;
  late TextEditingController _sampaiTanggalController;

  final List<String> _kategoriOptions = const [
    'Semua Kategori',
    'Iuran Warga',
    'Donasi',
    'Dana Bantuan Pemerintah',
    'Sumbangan Swadaya',
    'Hasil Usaha Kampung',
    'Pendapatan Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.initialFilters['nama']);
        
    _selectedKategori = widget.initialFilters['kategori'];
    if (_selectedKategori == 'Semua Kategori') {
      _selectedKategori = null;
    }

    _dariTanggalController = TextEditingController();
    if (widget.initialFilters['tanggal_mulai'] != null) {
      try {
        _dariTanggal = DateFormat('dd/MM/yyyy')
            .parse(widget.initialFilters['tanggal_mulai']!);
        _dariTanggalController.text = widget.initialFilters['tanggal_mulai']!;
      } catch (e) {
        // ignore
      }
    }

    _sampaiTanggalController = TextEditingController();
    if (widget.initialFilters['tanggal_akhir'] != null) {
      try {
        _sampaiTanggal = DateFormat('dd/MM/yyyy')
            .parse(widget.initialFilters['tanggal_akhir']!);
        _sampaiTanggalController.text = widget.initialFilters['tanggal_akhir']!;
      } catch (e) {
        // ignore
      }
    }
  }

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

  void _applyFilter() {
    Map<String, String> filters = {};
    if (_namaController.text.isNotEmpty) {
      filters['nama'] = _namaController.text;
    }
    if (_selectedKategori != null && _selectedKategori != 'Semua Kategori') {
      filters['kategori'] = _selectedKategori!;
    }
    if (_dariTanggal != null) {
      filters['tanggal_mulai'] = DateFormat('dd/MM/yyyy').format(_dariTanggal!);
    }
    if (_sampaiTanggal != null) {
      filters['tanggal_akhir'] = DateFormat('dd/MM/yyyy').format(_sampaiTanggal!);
    }
    widget.onFilterApplied(filters);
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
    widget.onFilterApplied({});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Pemasukan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextButton(
                onPressed: _resetFilter,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Nama', _namaController, 'Cari nama...'),
          const SizedBox(height: 16),
          _buildDropdown(
            'Kategori',
            _selectedKategori,
            _kategoriOptions,
            (val) {
              setState(() {
                _selectedKategori = val;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDateInput('Dari Tanggal', _dariTanggalController, true),
          const SizedBox(height: 16),
          _buildDateInput('Sampai Tanggal', _sampaiTanggalController, false),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _applyFilter,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Terapkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? selectedValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: const InputDecoration(
            hintText: 'Semua Kategori',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: items
              .map((value) =>
                  DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: onChanged,
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: '--/--/----',
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () => _selectDate(context, controller, isStartDate),
        ),
      ],
    );
  }
}