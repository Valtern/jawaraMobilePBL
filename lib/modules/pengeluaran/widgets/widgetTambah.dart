// lib/modules/pengeluaran/widgets/widgetTambah.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jawarapbl/services/pengeluaran_service.dart';
import 'package:jawarapbl/shared/models/pengeluaran_model.dart';

class TambahPengeluaranForm extends StatefulWidget {
  final Pengeluaran? pengeluaranToEdit;
  final VoidCallback? onSuccess; // Callback to notify success

  const TambahPengeluaranForm({
    super.key,
    this.pengeluaranToEdit,
    this.onSuccess,
  });

  @override
  State<TambahPengeluaranForm> createState() => _TambahPengeluaranFormState();
}

class _TambahPengeluaranFormState extends State<TambahPengeluaranForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _nominalController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String? _selectedKategori;
  File? _pickedFile;
  bool _isLoading = false;
  DateTime? _selectedDate;

  final List<String> _kategoriItems = [
    'Pemeliharaan Fasilitas',
    'Operasional',
    'Kegiatan',
    'Kebersihan',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.pengeluaranToEdit != null) {
      final item = widget.pengeluaranToEdit!;
      _namaController.text = item.nama;
      _selectedDate = item.tanggal;
      _tanggalController.text = DateFormat('yyyy-MM-dd').format(item.tanggal);
      _nominalController.text = item.nominal.toStringAsFixed(0);
      _deskripsiController.text = item.deskripsi ?? '';
      if (_kategoriItems.contains(item.kategori)) {
        _selectedKategori = item.kategori;
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalController.dispose();
    _nominalController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      // MODIFIED: Prevent picking future dates
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickFile() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedFile = File(picked.path);
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _tanggalController.clear();
    _nominalController.clear();
    _deskripsiController.clear();
    setState(() {
      _selectedKategori = null;
      _pickedFile = null;
      _selectedDate = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    final data = {
      'nama': _namaController.text,
      'tanggal': _tanggalController.text,
      'kategori': _selectedKategori!,
      'nominal': _nominalController.text,
      'deskripsi': _deskripsiController.text,
    };

    Map<String, dynamic> response;
    
    if (widget.pengeluaranToEdit == null) {
      // Create new
      response = await PengeluaranService().createPengeluaran(data, _pickedFile);
    } else {
      // Update existing
      response = await PengeluaranService().updatePengeluaran(
        widget.pengeluaranToEdit!.id.toString(),
        data,
        _pickedFile,
      );
    }

    setState(() { _isLoading = false; });

    if (!mounted) return;
    
    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.pengeluaranToEdit == null
              ? 'Pengeluaran berhasil dibuat'
              : 'Pengeluaran berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      _resetForm();
      widget.onSuccess?.call();
    } else {
      // Show the actual error message from the API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${response['message']}'), 
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.pengeluaranToEdit == null
                  ? 'Buat Pengeluaran Baru'
                  : 'Edit Pengeluaran',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _namaController,
              label: 'Nama Pengeluaran',
              hint: 'Masukkan nama pengeluaran',
              validator: (val) =>
                  val!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 20),
            _buildDateField(
              controller: _tanggalController,
              label: 'Tanggal Pengeluaran',
              validator: (val) =>
                  val!.isEmpty ? 'Tanggal tidak boleh kosong' : null,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Kategori Pengeluaran',
              hint: '-- Pilih Kategori --',
              items: _kategoriItems,
              selectedValue: _selectedKategori,
              validator: (val) =>
                  val == null ? 'Kategori tidak boleh kosong' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nominalController,
              label: 'Nominal',
              hint: 'Masukkan nominal',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (val) =>
                  val!.isEmpty ? 'Nominal tidak boleh kosong' : null,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _deskripsiController,
              label: 'Deskripsi (Opsional)',
              hint: 'Masukkan deskripsi',
              isMultiLine: true,
            ),
            const SizedBox(height: 20),
            _buildFileUploadField(label: 'Bukti Pengeluaran (Opsional)'),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool isMultiLine = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: isMultiLine ? 3 : 1,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: validator,
          decoration: InputDecoration(
            hintText: '-- / -- / ----',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickDate,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
    required String? selectedValue,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          hint: Text(hint),
          value: selectedValue,
          validator: validator,
          onChanged: (String? newValue) {
            setState(() {
              _selectedKategori = newValue;
            });
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileUploadField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: _pickedFile == null
                  ? Text(
                      'Upload bukti pengeluaran (.png/.jpg)',
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        Text(
                          'File terpilih: ${_pickedFile!.path.split('/').last}',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Submit'),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: _isLoading ? null : _resetForm,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}