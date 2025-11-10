import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/semuapemasukan_model.dart';
import 'package:jawarapbl/services/auth_services.dart';

// =========================================================================
// A. HALAMAN DETAIL PEMASUKAN
// =========================================================================

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

// -------------------------------------------------------------------------
// B. KODE FILTER PEMASUKAN
// -------------------------------------------------------------------------

class FilterPemasukanDialog extends StatefulWidget {
  const FilterPemasukanDialog({super.key});

  @override
  State<FilterPemasukanDialog> createState() => _FilterPemasukanDialogState();
}

class _FilterPemasukanDialogState extends State<FilterPemasukanDialog> {
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
            const Text('Kategori'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedKategori,
              decoration: const InputDecoration(
                hintText: '-- Pilih Kategori --',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: _kategoriOptions
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedKategori = newValue;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildDateInput(
              'Dari Tanggal',
              _dariTanggalController,
              _dariTanggal,
              true,
            ),
            _buildDateInput(
              'Sampai Tanggal',
              _sampaiTanggalController,
              _sampaiTanggal,
              false,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        OutlinedButton(
          onPressed: _resetFilter,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            foregroundColor: Colors.black54,
            backgroundColor: Colors.grey[50],
          ),
          child: const Text('Reset Filter'),
        ),
        ElevatedButton(
          onPressed: () {
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

// -------------------------------------------------------------------------
// C. SEMUA PEMASUKAN PAGE (DARI API) + CRUD BUTTON
// -------------------------------------------------------------------------

class SemuaPemasukanPage extends StatefulWidget {
  const SemuaPemasukanPage({super.key});

  @override
  State<SemuaPemasukanPage> createState() => _SemuaPemasukanPageState();
}

class _SemuaPemasukanPageState extends State<SemuaPemasukanPage> {
  late Future<List<PemasukanModel>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _fetchPemasukan();
  }

  Future<List<PemasukanModel>> _fetchPemasukan() async {
    final response = await http.get(
      Uri.parse('${AuthService().baseUrl}/pemasukan'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // ✅ Ubah Map ke List
      final List data = body.values.toList();

      return data.map((e) => PemasukanModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data pemasukan');
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FilterPemasukanDialog(),
    );
  }

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

  // =====================================================
  // 🔹 Tambahan: Fungsi Create / Update / Delete
  // =====================================================

  void _createData() async {
    final response = await http.post(
      Uri.parse('${AuthService().baseUrl}/pemasukan'),
      body: {
        'name': 'Pemasukan Baru',
        'jenis': 'Iuran Warga',
        'nominal': '100000',
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      setState(() {
        _futureData = _fetchPemasukan();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menambah data')));
    }
  }

  void _updateData(int id) async {
    final response = await http.put(
      Uri.parse('${AuthService().baseUrl}/pemasukan/$id'),
      body: {
        'name': 'Update Nama',
        'jenis': 'Donasi',
        'nominal': '200000',
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _futureData = _fetchPemasukan();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memperbarui data')));
    }
  }

  void _deleteData(int id) async {
    final response = await http.delete(
      Uri.parse('${AuthService().baseUrl}/pemasukan/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _futureData = _fetchPemasukan();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus data')));
    }
  }

  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn1',
        backgroundColor: Colors.green,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const TambahPemasukanDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
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
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data pemasukan.'));
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
                        subtitle: Text(
                          '${item.jenisPemasukan} • ${item.tanggal}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => EditPemasukanDialog(
                                    item: item,
                                    onSaved: () {
                                      setState(() {
                                        _futureData = _fetchPemasukan();
                                      });
                                    },
                                  ),
                                );
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteData(item.no),
                            ),
                          ],
                        ),
                        onTap: () => _handleCardAction(context, 'Detail', item),
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
                onPressed: () => _showFilterDialog(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TambahPemasukanDialog extends StatefulWidget {
  const TambahPemasukanDialog({super.key});

  @override
  State<TambahPemasukanDialog> createState() => _TambahPemasukanDialogState();
}

class _TambahPemasukanDialogState extends State<TambahPemasukanDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jenisController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('${AuthService().baseUrl}/pemasukan');
    final body = {
      'name': _namaController.text,
      'jenis': _jenisController.text,
      'nominal': _nominalController.text,
      'tanggal': _tanggalController.text,
    };

    final response = await http.post(url, body: body);

    if (response.statusCode == 201) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menambah data')));
    }
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Pemasukan'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
              validator: (value) =>
                  value!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            TextFormField(
              controller: _jenisController,
              decoration: const InputDecoration(labelText: 'Jenis'),
              validator: (value) =>
                  value!.isEmpty ? 'Jenis tidak boleh kosong' : null,
            ),
            TextFormField(
              controller: _nominalController,
              decoration: const InputDecoration(labelText: 'Nominal'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Nominal tidak boleh kosong' : null,
            ),
            TextFormField(
              controller: _tanggalController,
              readOnly: true,
              onTap: () => _pilihTanggal(context),
              decoration: const InputDecoration(labelText: 'Tanggal'),
              validator: (value) =>
                  value!.isEmpty ? 'Tanggal tidak boleh kosong' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _simpanData, child: const Text('Simpan')),
      ],
    );
  }
}

class EditPemasukanDialog extends StatefulWidget {
  final PemasukanModel item;
  final Function() onSaved;

  const EditPemasukanDialog({
    super.key,
    required this.item,
    required this.onSaved,
  });

  @override
  State<EditPemasukanDialog> createState() => _EditPemasukanDialogState();
}

class _EditPemasukanDialogState extends State<EditPemasukanDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _jenisController;
  late TextEditingController _nominalController;
  late TextEditingController _tanggalController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.item.nama);
    _jenisController = TextEditingController(text: widget.item.jenisPemasukan);
    _nominalController = TextEditingController(
      text: widget.item.nominal.toString(),
    );
    _tanggalController = TextEditingController(text: widget.item.tanggal);
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.item.tanggal) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.put(
      Uri.parse('${AuthService().baseUrl}/pemasukan/${widget.item.no}'),
      body: {
        'name': _namaController.text,
        'jenis': _jenisController.text,
        'nominal': _nominalController.text,
        'tanggal': _tanggalController.text,
      },
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memperbarui data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Pemasukan'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _jenisController,
                decoration: const InputDecoration(labelText: 'Jenis'),
                validator: (value) =>
                    value!.isEmpty ? 'Jenis tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _nominalController,
                decoration: const InputDecoration(labelText: 'Nominal'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Nominal tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Tanggal'),
                onTap: () => _pilihTanggal(context),
                validator: (value) =>
                    value!.isEmpty ? 'Tanggal tidak boleh kosong' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(onPressed: _updateData, child: const Text('Simpan')),
      ],
    );
  }
}
