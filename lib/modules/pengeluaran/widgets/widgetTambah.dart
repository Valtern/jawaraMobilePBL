import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jawarapbl/services/pengeluaran_service.dart';
import 'package:jawarapbl/shared/models/pengeluaran_model.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';

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
    final nama = _namaController.text.trim();
    final tanggal = _tanggalController.text.trim();
    final nominalStr = _nominalController.text.trim();

    if (nama.isEmpty ||
        tanggal.isEmpty ||
        nominalStr.isEmpty ||
        _selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama, tanggal, kategori, dan nominal wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final data = {
      'nama': nama,
      'tanggal': tanggal,
      'kategori': _selectedKategori!,
      'nominal': nominalStr,
      'deskripsi': _deskripsiController.text.trim(),
    };

    Map<String, dynamic> response;

    if (widget.pengeluaranToEdit == null) {
      // Create new
      response =
          await PengeluaranService().createPengeluaran(data, _pickedFile);
    } else {
      // Update existing
      response = await PengeluaranService().updatePengeluaran(
        widget.pengeluaranToEdit!.id.toString(),
        data,
        _pickedFile,
      );
    }

    setState(() {
      _isLoading = false;
    });

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
              Text(
                widget.pengeluaranToEdit == null
                    ? 'Tambah Pengeluaran'
                    : 'Edit Pengeluaran',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 8),
              TextInput(
                controller: _namaController,
                label: 'Nama Pengeluaran',
                prefixIcon: const Icon(Icons.description),
              ),
              const SizedBox(height: 16),
              TextInput(
                controller: _tanggalController,
                label: 'Tanggal Pengeluaran',
                prefixIcon: const Icon(Icons.calendar_today),
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              SelectInput<String>(
                label: 'Kategori Pengeluaran',
                prefixIcon: const Icon(Icons.category),
                value: _selectedKategori,
                items: _kategoriItems
                    .map((kategori) => DropdownMenuItem(
                        value: kategori, child: Text(kategori)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextInput(
                controller: _nominalController,
                label: 'Nominal',
                prefixIcon: const Icon(Icons.attach_money),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextInput(
                controller: _deskripsiController,
                label: 'Deskripsi (Opsional)',
                prefixIcon: const Icon(Icons.notes),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildFileUploadField(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Color(0xFF6938EF),
                ),
                const SizedBox(width: 8),
                const Text(
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
            onPressed: _isLoading ? null : _submitForm,
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.save_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.pengeluaranToEdit == null
                            ? 'Simpan'
                            : 'Perbarui',
                        style: const TextStyle(
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

  Widget _buildFileUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti Pengeluaran (Opsional)',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Center(
              child: _pickedFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload bukti pengeluaran (.png/.jpg)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'File terpilih: ${_pickedFile!.path.split('/').last}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
