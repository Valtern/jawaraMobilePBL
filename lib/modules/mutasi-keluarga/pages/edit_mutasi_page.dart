import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/models/mutasi_keluarga_model.dart';
import 'package:jawarapbl/services/mutasi_keluarga_service.dart';

class EditMutasiPage extends StatefulWidget {
  final MutasiKeluarga mutasi;

  const EditMutasiPage({super.key, required this.mutasi});

  @override
  State<EditMutasiPage> createState() => _EditMutasiPageState();
}

class _EditMutasiPageState extends State<EditMutasiPage> {
  final MutasiKeluargaService _service = MutasiKeluargaService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _keteranganController;
  late DateTime _selectedDate;
  late String _selectedJenisMutasi;
  late Keluarga _selectedKeluarga;
  
  List<Keluarga> _keluargaList = [];
  bool _isLoading = false;
  bool _isFetchingData = true;

  final List<String> _jenisMutasiOptions = [
    'Pindah Datang',
    'Pindah Keluar',
    'Kematian',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchKeluargaList();
  }

  void _initializeData() {
    _keteranganController = TextEditingController(text: widget.mutasi.keterangan ?? '');
    _selectedDate = widget.mutasi.tanggalMutasi;
    _selectedJenisMutasi = widget.mutasi.jenisMutasi;
    _selectedKeluarga = widget.mutasi.keluarga ?? Keluarga(id: 0, namaKeluarga: '', nomorKk: '');
  }

  Future<void> _fetchKeluargaList() async {
    final keluargaList = await _service.getKeluargaList();
    setState(() {
      _keluargaList = keluargaList;
      _isFetchingData = false;
      if (_selectedKeluarga.id == 0 && keluargaList.isNotEmpty) {
        _selectedKeluarga = keluargaList.first;
      }
    });
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Mutasi Keluarga',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Edit Data Mutasi Keluarga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),

                _buildKeluargaDropdown(),
                _buildJenisMutasiDropdown(),
                _buildDateField(),
                _buildKeteranganField(),

                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _updateMutasi,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeluargaDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Keluarga>(
        decoration: InputDecoration(
          labelText: 'Keluarga',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: _keluargaList.any((k) => k.id == _selectedKeluarga.id)
            ? _keluargaList.firstWhere((k) => k.id == _selectedKeluarga.id)
            : (_keluargaList.isNotEmpty ? _keluargaList.first : null),
        isExpanded: true,
        selectedItemBuilder: (context) => _keluargaList
            .map((k) => Text(
                  k.namaKeluarga,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ))
            .toList(),
        items: _keluargaList.map((keluarga) {
          return DropdownMenuItem(
            value: keluarga,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(keluarga.namaKeluarga, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  'KK: ${keluarga.nomorKk}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedKeluarga = value!;
          });
        },
        validator: (value) => value == null ? 'Harap pilih keluarga' : null,
      ),
    );
  }

  Widget _buildJenisMutasiDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Jenis Mutasi',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: _selectedJenisMutasi,
        items: _jenisMutasiOptions.map((jenis) {
          return DropdownMenuItem(value: jenis, child: Text(jenis));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedJenisMutasi = value!;
          });
        },
        validator: (value) => value == null ? 'Harap pilih jenis mutasi' : null,
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Tanggal Mutasi',
          prefixIcon: const Icon(Icons.date_range, color: Colors.deepPurple),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        controller: TextEditingController(text: _formatDate(_selectedDate)),
        onTap: _selectDate,
        validator: (value) => value == null || value.isEmpty ? 'Harap pilih tanggal' : null,
      ),
    );
  }

  Widget _buildKeteranganField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _keteranganController,
        decoration: InputDecoration(
          labelText: 'Keterangan',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        maxLines: 3,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  Future<void> _updateMutasi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedMutasi = MutasiKeluarga(
      id: widget.mutasi.id,
      keluargaId: _selectedKeluarga.id,
      jenisMutasi: _selectedJenisMutasi,
      tanggalMutasi: _selectedDate,
      keterangan: _keteranganController.text.trim().isEmpty 
          ? null 
          : _keteranganController.text.trim(),
    );

    final success = await _service.updateMutasiKeluarga(updatedMutasi);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data mutasi berhasil diperbarui')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui data mutasi')),
      );
    }
  }
}
