import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/models/mutasi_keluarga_model.dart';
import 'package:jawarapbl/services/mutasi_keluarga_service.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';

class TambahMutasiForm extends StatefulWidget {
  const TambahMutasiForm({super.key});

  @override
  State<TambahMutasiForm> createState() => _TambahMutasiFormState();
}

class _TambahMutasiFormState extends State<TambahMutasiForm> {
  final MutasiKeluargaService _service = MutasiKeluargaService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _keteranganController;
  late TextEditingController _tanggalController;
  late DateTime _selectedDate;
  late String _selectedJenisMutasi;
  Keluarga? _selectedKeluarga;

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
    _keteranganController = TextEditingController();
    _selectedDate = DateTime.now();
    _tanggalController =
        TextEditingController(text: _formatDate(_selectedDate));
    _selectedJenisMutasi = _jenisMutasiOptions.first;
    _selectedKeluarga = null;
  }

  Future<void> _fetchKeluargaList() async {
    final keluargaList = await _service.getKeluargaList();
    setState(() {
      _keluargaList = keluargaList;
      _isFetchingData = false;
      if (_selectedKeluarga == null && keluargaList.isNotEmpty) {
        _selectedKeluarga = keluargaList.first;
      }
    });
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_keluargaList.isEmpty) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Mutasi Keluarga',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Data keluarga tidak tersedia.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pastikan server API dapat diakses dari perangkat dan base URL sudah benar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _fetchKeluargaList,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Muat Ulang'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Mutasi Keluarga',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildKeluargaDropdown(),
                    const SizedBox(height: 16),
                    _buildJenisMutasiDropdown(),
                    const SizedBox(height: 16),
                    _buildDateField(),
                    const SizedBox(height: 16),
                    _buildKeteranganField(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    _keteranganController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _tanggalController.text = _formatDate(_selectedDate);
      _selectedJenisMutasi = _jenisMutasiOptions.first;
      _selectedKeluarga = null;
    });
  }

  Widget _buildKeluargaDropdown() {
    return DropdownButtonFormField<Keluarga>(
      initialValue: _keluargaList.any((k) => _selectedKeluarga?.id == k.id)
          ? _selectedKeluarga
          : null,
      isExpanded: true,
      selectedItemBuilder: (context) {
        return _keluargaList.map((k) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${k.namaKeluarga} (KK: ${k.nomorKk})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          );
        }).toList();
      },
      items: _keluargaList.map((keluarga) {
        return DropdownMenuItem(
          value: keluarga,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                keluarga.namaKeluarga,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'KK: ${keluarga.nomorKk}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedKeluarga = value;
        });
      },
      validator: (value) => value == null ? 'Harap pilih keluarga' : null,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        labelText: 'Keluarga',
        prefixIcon: const Icon(Icons.family_restroom),
      ),
    );
  }

  Widget _buildJenisMutasiDropdown() {
    return SelectInput<String>(
      label: 'Jenis Mutasi',
      prefixIcon: const Icon(Icons.swap_horiz),
      value: _selectedJenisMutasi,
      items: _jenisMutasiOptions
          .map((jenis) => DropdownMenuItem(value: jenis, child: Text(jenis)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedJenisMutasi = value;
        });
      },
    );
  }

  Widget _buildDateField() {
    return TextInput(
      controller: _tanggalController,
      label: 'Tanggal Mutasi',
      prefixIcon: const Icon(Icons.calendar_today),
      readOnly: true,
      onTap: _selectDate,
    );
  }

  Widget _buildKeteranganField() {
    return TextInput(
      controller: _keteranganController,
      label: 'Keterangan',
      prefixIcon: const Icon(Icons.notes),
      maxLines: 3,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : _resetForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(
                color: Color(0xFF6938EF),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Color(0xFF6938EF),
                ),
                SizedBox(width: 8),
                Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6938EF),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveMutasi,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6938EF),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Menyimpan...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.save_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
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
        _tanggalController.text = _formatDate(_selectedDate);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }

  Future<void> _saveMutasi() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedKeluarga == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih keluarga')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final mutasi = MutasiKeluarga(
      keluargaId: _selectedKeluarga!.id,
      jenisMutasi: _selectedJenisMutasi,
      tanggalMutasi: _selectedDate,
      keterangan: _keteranganController.text.trim().isEmpty
          ? null
          : _keteranganController.text.trim(),
    );

    final success = await _service.createMutasiKeluarga(mutasi);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data mutasi berhasil ditambahkan')),
      );
      _formKey.currentState?.reset();
      _initializeData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan data mutasi')),
      );
    }
  }
}
