import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/models/mutasi_keluarga_model.dart';
import 'package:jawarapbl/services/mutasi_keluarga_service.dart';
import 'package:jawarapbl/shared/widgets/add_data_popup.dart';

class TambahMutasiForm extends StatefulWidget {
  const TambahMutasiForm({super.key});

  @override
  State<TambahMutasiForm> createState() => _TambahMutasiFormState();
}

class _TambahMutasiFormState extends State<TambahMutasiForm> {
  final MutasiKeluargaService _service = MutasiKeluargaService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _keteranganController;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_keluargaList.isEmpty) {
      return AddDataPopup(
        title: 'Tambah Mutasi Keluarga',
        onSave: () {},
        onReset: _resetForm,
        isLoading: false,
        formFields: [
          const SizedBox(height: 8),
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
      );
    }

    return AddDataPopup(
      title: 'Tambah Mutasi Keluarga',
      onSave: _saveMutasi,
      onReset: _resetForm,
      isLoading: _isLoading,
      formFields: [
        const SizedBox(height: 8),
        _buildKeluargaDropdown(),
        const SizedBox(height: 16),
        _buildJenisMutasiDropdown(),
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        _buildKeteranganField(),
        const SizedBox(height: 8),
      ],
    );
  }

  void _resetForm() {
    _keteranganController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedJenisMutasi = _jenisMutasiOptions.first;
      _selectedKeluarga = null;
    });
  }

  Widget _buildKeluargaDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<Keluarga>(
        decoration: InputDecoration(
          labelText: 'Keluarga',
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        hint: const Text('Pilih keluarga'),
        initialValue: _keluargaList.any((k) => _selectedKeluarga?.id == k.id)
            ? _selectedKeluarga
            : null,
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
                Text(keluarga.namaKeluarga,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
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
            _selectedKeluarga = value;
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
        initialValue: _selectedJenisMutasi,
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
        validator: (value) =>
            value == null || value.isEmpty ? 'Harap pilih tanggal' : null,
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
    if (!_formKey.currentState!.validate()) return;

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
