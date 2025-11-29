import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawarapbl/services/pemasukan_laporan_service.dart';
import 'package:jawarapbl/services/pengeluaran_service.dart';
import 'package:jawarapbl/shared/models/pengeluaran_model.dart';
import 'package:jawarapbl/modules/laporan-keuangan/models/semuapemasukan_model.dart';
import '../helpers/laporan_pdf_generator.dart';
import '../models/cetaklaporan_model.dart';
import '../widgets/cetaklaporan_widget.dart';

class CetakLaporanPage extends StatefulWidget {
  const CetakLaporanPage({super.key});

  @override
  State<CetakLaporanPage> createState() => _CetakLaporanPageState();
}

class _CetakLaporanPageState extends State<CetakLaporanPage> {
  DateTime? _dariTanggal;
  DateTime? _sampaiTanggal;
  String? _selectedKategori;
  bool _isLoading = false;
  String? _error;

  final List<String> _kategoriOptions = const [
    'Semua',
    'Pemasukan',
    'Pengeluaran',
  ];

  List<LaporanItem> _items = [];
  final Set<LaporanItem> _selectedItems = {};

  final TextEditingController _dariTanggalController = TextEditingController();
  final TextEditingController _sampaiTanggalController =
      TextEditingController();

  final PemasukanLaporanService _pemasukanService = PemasukanLaporanService();
  final PengeluaranService _pengeluaranService = PengeluaranService();

  @override
  void dispose() {
    _dariTanggalController.dispose();
    _sampaiTanggalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
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
          _dariTanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _sampaiTanggal = picked;
          _sampaiTanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  Future<void> _fetchData() async {
    if (_selectedKategori == null) {
      setState(() {
        _error = 'Harap pilih kategori terlebih dahulu.';
      });
      return;
    }

    // NEW: Only validate date range if both dates are actually set
    if (_dariTanggal != null &&
        _sampaiTanggal != null &&
        _dariTanggal!.isAfter(_sampaiTanggal!)) {
      setState(() {
        _error = 'Tanggal "Dari" tidak boleh setelah "Sampai".';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _items = [];
      _selectedItems.clear();
    });

    try {
      List<LaporanItem> fetchedItems = [];

      // Fetch Pemasukan
      if (_selectedKategori == 'Pemasukan' || _selectedKategori == 'Semua') {
        List<PemasukanModel> pemasukan =
            await _pemasukanService.getLaporanPemasukan();
        
        // NEW: In-app date filtering that handles null dates
        var filteredPemasukan = pemasukan.where((item) {
          if (_dariTanggal != null &&
              item.tanggalSort.isBefore(_dariTanggal!)) {
            return false;
          }
          if (_sampaiTanggal != null &&
              item.tanggalSort.isAfter(_sampaiTanggal!)) {
            return false;
          }
          return true;
        });

        fetchedItems.addAll(filteredPemasukan
            .map((item) => LaporanItem(
                  id: 'p-${item.no}',
                  nama: item.nama,
                  kategori: item.jenisPemasukan,
                  nominal: item.nominal,
                  tanggal: item.tanggalSort,
                  tipe: LaporanItemTipe.pemasukan,
                )));
      }

      // Fetch Pengeluaran
      if (_selectedKategori == 'Pengeluaran' || _selectedKategori == 'Semua') {
        
        // NEW: Conditionally build the filter map
        Map<String, String> filters = {};
        if (_dariTanggal != null) {
          filters['tanggal_mulai'] =
              _dariTanggal!.toIso8601String().split('T').first;
        }
        if (_sampaiTanggal != null) {
          filters['tanggal_akhir'] =
              _sampaiTanggal!.toIso8601String().split('T').first;
        }

        List<Pengeluaran> pengeluaran =
            await _pengeluaranService.getPengeluaran(filters);
            
        fetchedItems.addAll(pengeluaran
            .map((item) => LaporanItem(
                  id: 'k-${item.id}',
                  nama: item.nama,
                  kategori: item.kategori,
                  nominal: item.nominal,
                  tanggal: item.tanggal,
                  tipe: LaporanItemTipe.pengeluaran,
                )));
      }

      fetchedItems.sort((a, b) => a.tanggal.compareTo(b.tanggal));

      setState(() {
        _items = fetchedItems;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(LaporanItem item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedItems.length == _items.length) {
        _selectedItems.clear();
      } else {
        _selectedItems.clear();
        _selectedItems.addAll(_items);
      }
    });
  }

Future<void> _printLaporan() async {
  if (_selectedItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Tidak ada item yang dipilih untuk dicetak.')),
    );
    return;
  }

  await LaporanPdfGenerator.generateAndPrintPdf(
    context, 
    _selectedItems.toList(),
    _dariTanggal ?? DateTime(2000), // Use a default start if null
    _sampaiTanggal ?? DateTime.now(), // Use today as default end if null
    _selectedKategori ?? 'Semua',
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterSection(),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                  child: Center(
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red))))
            else if (_items.isEmpty)
              const Expanded(
                  child: Center(
                      child: Text('Tidak ada data. Silakan tekan "Cari".')))
            else
              _buildResultsSection(),
          ],
        ),
      ),
      bottomNavigationBar: _items.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _selectedItems.isEmpty ? null : _printLaporan,
                child: Text('Cetak Laporan (${_selectedItems.length} Item)',
                    style: const TextStyle(color: Colors.white)),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Laporan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildDateInput(
                        'Dari Tanggal', _dariTanggalController, true)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildDateInput(
                        'Sampai Tanggal', _sampaiTanggalController, false)),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedKategori,
              decoration: const InputDecoration(
                hintText: '-- Pilih Kategori --',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: _kategoriOptions
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (newValue) => setState(() {
                _selectedKategori = newValue;
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _isLoading ? null : _fetchData,
              child: const Text('Cari'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInput(
    String label,
    TextEditingController controller,
    bool isStartDate,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context, isStartDate),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hasil Pencarian (${_items.length})',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: _selectAll,
                child: Text(
                  _selectedItems.length == _items.length
                      ? 'Batal Pilih Semua'
                      : 'Pilih Semua',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isSelected = _selectedItems.contains(item);
                return SelectableLaporanCard(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _onItemTapped(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}