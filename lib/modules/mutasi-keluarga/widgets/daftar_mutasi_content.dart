import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/widgets/mutasi_card.dart';
import 'package:jawarapbl/shared/models/mutasi_keluarga_model.dart';
import 'package:jawarapbl/services/mutasi_keluarga_service.dart';

class DaftarMutasiContent extends StatefulWidget {
  const DaftarMutasiContent({super.key});

  @override
  State<DaftarMutasiContent> createState() => _DaftarMutasiContentState();
}

class _DaftarMutasiContentState extends State<DaftarMutasiContent> {
  final MutasiKeluargaService _service = MutasiKeluargaService();
  List<MutasiKeluarga> _mutasiList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMutasiList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when user returns to this tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _fetchMutasiList() async {
    final mutasiList = await _service.getMutasiKeluarga();
    setState(() {
      _mutasiList = mutasiList;
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _fetchMutasiList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul halaman
          const Text(
            'Daftar Mutasi Keluarga',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 20),

          // Daftar card-based list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mutasiList.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada data mutasi keluarga',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        child: ListView.separated(
                          itemCount: _mutasiList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final mutasi = _mutasiList[index];
                            final mutasiData = MutasiData(
                              nama: mutasi.keluarga?.namaKeluarga ?? 'Unknown',
                              tanggal: _formatDate(mutasi.tanggalMutasi),
                              jenis: mutasi.jenisMutasi,
                            );
                            return MutasiCard(
                              item: mutasiData,
                              onTap: () => _navigateToDetail(mutasi.id!),
                              onEdit: () => _navigateToEdit(mutasi),
                              onDelete: () => _showDeleteConfirmation(mutasi),
                            );
                          },
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

  void _navigateToDetail(int mutasiId) {
    Navigator.pushNamed(context, '/detail-mutasi', arguments: mutasiId);
  }

  void _navigateToEdit(MutasiKeluarga mutasi) {
    Navigator.pushNamed(context, '/edit-mutasi', arguments: mutasi);
  }

  void _showDeleteConfirmation(MutasiKeluarga mutasi) {
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
                final success = await _service.deleteMutasiKeluarga(mutasi.id!);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data mutasi berhasil dihapus')),
                  );
                  _refreshData();
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
