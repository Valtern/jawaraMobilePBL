import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/semuapengeluaran_model.dart';

// =========================================================================
// A. HALAMAN DETAIL PENGELUARAN
// =========================================================================

class DetailPengeluaranPage extends StatelessWidget {
  final PengeluaranModel item;
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
                  item.nominalRupiah,
                  valueColor: Colors.red.shade700,
                ),
                _buildDetailRow('Verifikator', verifikator),
                _buildDetailRow('Tanggal Transaksi', item.tanggal),
                _buildDetailRow('Deskripsi', item.deskripsi ?? '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// B. KODE FILTER PENGELUARAN
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
// C. SEMUA PENGELUARAN PAGE (DARI API) + CRUD BUTTON
// -------------------------------------------------------------------------

class SemuaPengeluaranPage extends StatefulWidget {
  const SemuaPengeluaranPage({super.key});

  @override
  State<SemuaPengeluaranPage> createState() => _SemuaPengeluaranPageState();
}

class _SemuaPengeluaranPageState extends State<SemuaPengeluaranPage> {
  late Future<List<PengeluaranModel>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _fetchPengeluaran();
  }

  Future<List<PengeluaranModel>> _fetchPengeluaran() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.5:8000/api/pengeluaran'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body is List ? body : body.values.toList();
      return data.map((e) => PengeluaranModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data pengeluaran');
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FilterPengeluaranDialog(),
    );
  }

  void _deleteData(int id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.0.5:8000/api/pengeluaran/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _futureData = _fetchPengeluaran();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => TambahPengeluaranDialog(
              onSaved: () {
                setState(() {
                  _futureData = _fetchPengeluaran();
                });
              },
            ),
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
            child: FutureBuilder<List<PengeluaranModel>>(
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
                        subtitle: Text('${item.kategori} • ${item.tanggal}'),
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
                                  builder: (context) => EditPengeluaranDialog(
                                    item: item,
                                    onSaved: () {
                                      setState(() {
                                        _futureData = _fetchPengeluaran();
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteData(item.id),
                            ),
                          ],
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

// -------------------------------------------------------------------------
// D. TAMBAH & EDIT PENGELUARAN DIALOG
// -------------------------------------------------------------------------

class TambahPengeluaranDialog extends StatefulWidget {
  final Function() onSaved;

  const TambahPengeluaranDialog({super.key, required this.onSaved});

  @override
  State<TambahPengeluaranDialog> createState() =>
      _TambahPengeluaranDialogState();
}

class _TambahPengeluaranDialogState extends State<TambahPengeluaranDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.post(
      Uri.parse('http://192.168.0.5:8000/api/pengeluaran'),
      body: {
        'user_id': '1',
        'nama': _namaController.text,
        'kategori': _kategoriController.text,
        'nominal': _nominalController.text,
        'tanggal': _tanggalController.text,
        'deskripsi': _deskripsiController.text,
      },
    );

    if (response.statusCode == 201) {
      Navigator.pop(context);
      widget.onSaved();
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
      title: const Text('Tambah Pengeluaran'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Pengeluaran'),
              validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
            ),
            TextFormField(
              controller: _kategoriController,
              decoration: const InputDecoration(labelText: 'Kategori'),
              validator: (value) =>
                  value!.isEmpty ? 'Kategori wajib diisi' : null,
            ),
            TextFormField(
              controller: _nominalController,
              decoration: const InputDecoration(labelText: 'Nominal'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Nominal wajib diisi' : null,
            ),
            TextFormField(
              controller: _tanggalController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Tanggal'),
              onTap: () => _pilihTanggal(context),
              validator: (value) =>
                  value!.isEmpty ? 'Tanggal wajib diisi' : null,
            ),
            TextFormField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _simpanData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------------
// E. EDIT PENGELUARAN DIALOG
// -------------------------------------------------------------------------

class EditPengeluaranDialog extends StatefulWidget {
  final PengeluaranModel item;
  final Function() onSaved;

  const EditPengeluaranDialog({
    super.key,
    required this.item,
    required this.onSaved,
  });

  @override
  State<EditPengeluaranDialog> createState() => _EditPengeluaranDialogState();
}

class _EditPengeluaranDialogState extends State<EditPengeluaranDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _kategoriController;
  late TextEditingController _nominalController;
  late TextEditingController _tanggalController;
  late TextEditingController _deskripsiController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.item.nama);
    _kategoriController = TextEditingController(text: widget.item.kategori);
    _nominalController = TextEditingController(
      text: widget.item.nominal.toString(),
    );
    _tanggalController = TextEditingController(text: widget.item.tanggal);
    _deskripsiController = TextEditingController(
      text: widget.item.deskripsi ?? '',
    );
  }

  Future<void> _editData() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.put(
      Uri.parse('http://192.168.0.5:8000/api/pengeluaran/${widget.item.id}'),
      body: {
        'nama': _namaController.text,
        'kategori': _kategoriController.text,
        'nominal': _nominalController.text,
        'tanggal': _tanggalController.text,
        'deskripsi': _deskripsiController.text,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Pengeluaran'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Pengeluaran'),
              validator: (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
            ),
            TextFormField(
              controller: _kategoriController,
              decoration: const InputDecoration(labelText: 'Kategori'),
              validator: (value) =>
                  value!.isEmpty ? 'Kategori wajib diisi' : null,
            ),
            TextFormField(
              controller: _nominalController,
              decoration: const InputDecoration(labelText: 'Nominal'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Nominal wajib diisi' : null,
            ),
            TextFormField(
              controller: _tanggalController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Tanggal'),
              onTap: () => _pilihTanggal(context),
              validator: (value) =>
                  value!.isEmpty ? 'Tanggal wajib diisi' : null,
            ),
            TextFormField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _editData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Simpan', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
