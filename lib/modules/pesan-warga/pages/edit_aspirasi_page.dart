import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pesan-warga/models/informasiaspirasi_model.dart';
import 'package:jawarapbl/services/pesan_service.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';

class EditAspirasiPage extends StatefulWidget {
  final AspirasiWarga aspirasi;

  const EditAspirasiPage({super.key, required this.aspirasi});

  @override
  State<EditAspirasiPage> createState() => _EditAspirasiPageState();
}

class _EditAspirasiPageState extends State<EditAspirasiPage> {
  final _pesanService = PesanService();
  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.aspirasi.judul);
    _deskripsiController =
        TextEditingController(text: widget.aspirasi.deskripsi);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    if (_judulController.text.isEmpty || _deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Judul dan deskripsi tidak boleh kosong.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedAspirasi = await _pesanService.updateAspirasi(
        id: widget.aspirasi.id,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aspirasi berhasil diperbarui.'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, updatedAspirasi);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Aspirasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextInput(
              controller: _judulController,
              label: 'Judul Aspirasi',
            ),
            const SizedBox(height: 16),
            TextInput(
              controller: _deskripsiController,
              label: 'Deskripsi Aspirasi',
              maxLines: 8,
            ),
            const SizedBox(height: 24),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _submitEdit,
                    child: const Text('Simpan Perubahan'),
                  ),
          ],
        ),
      ),
    );
  }
}