import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/models/mutasi_keluarga_model.dart';
import 'package:jawarapbl/services/mutasi_keluarga_service.dart';

class DetailMutasiPage extends StatefulWidget {
  final int mutasiId;

  const DetailMutasiPage({super.key, required this.mutasiId});

  @override
  State<DetailMutasiPage> createState() => _DetailMutasiPageState();
}

class _DetailMutasiPageState extends State<DetailMutasiPage> {
  final MutasiKeluargaService _service = MutasiKeluargaService();
  MutasiKeluarga? _mutasi;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMutasiDetail();
  }

  Future<void> _fetchMutasiDetail() async {
    final mutasi = await _service.getMutasiKeluargaById(widget.mutasiId);
    setState(() {
      _mutasi = mutasi;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Mutasi Keluarga',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mutasi == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : _buildDetailContent(),
    );
  }

  Widget _buildDetailContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Mutasi Keluarga',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Nama Keluarga', _mutasi!.keluarga?.namaKeluarga ?? '-'),
              _buildInfoRow('Nomor KK', _mutasi!.keluarga?.nomorKk ?? '-'),
              _buildInfoRow('Alamat', _mutasi!.keluarga?.rumah?.alamat ?? '-'),
              const Divider(height: 32),
              _buildInfoRow('Jenis Mutasi', _mutasi!.jenisMutasi),
              _buildInfoRow('Tanggal Mutasi', _formatDate(_mutasi!.tanggalMutasi)),
              if (_mutasi!.keterangan != null && _mutasi!.keterangan!.isNotEmpty)
                _buildInfoRow('Keterangan', _mutasi!.keterangan!),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/edit-mutasi',
                          arguments: _mutasi,
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showDeleteConfirmation,
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus data mutasi ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await _service.deleteMutasiKeluarga(_mutasi!.id!);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data mutasi berhasil dihapus')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menghapus data mutasi')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
