import 'package:flutter/material.dart';
import 'package:jawarapbl/services/auth_services.dart';
import '../models/penerimaanwarga_model.dart';

final AuthService authService = AuthService();

class PenerimaanWargaPage extends StatefulWidget {
  const PenerimaanWargaPage({super.key});

  @override
  State<PenerimaanWargaPage> createState() => _PenerimaanWargaPageState();
}

class _PenerimaanWargaPageState extends State<PenerimaanWargaPage> {
  late Future<List<PenerimaanWarga>> _futureList;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _futureList = _loadData(); // Initialize _futureList here
  }

  Future<List<PenerimaanWarga>> _loadData() async {
    if (!mounted) return [];

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await authService.getPenerimaanWarga();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return data;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat data: ${e.toString()}';
        });
      }
      return []; // Return empty list on error
    }
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _futureList = _loadData();
      });
    }
  }

  void _openDetail(PenerimaanWarga item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPenerimaanPage(item: item)),
    );
  }

  void _openEdit(PenerimaanWarga item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditPenerimaanWargaPage(item: item)),
    ).then((_) => _refresh());
  }

  void _confirmDelete(PenerimaanWarga item) {
    showDialog(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        item: item,
        onConfirm: () async {
          // Fixed: Removed dead null check (?? 0)
          final ok = await authService.deletePenerimaan(item.id);
          if (ok) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  // Fixed: Removed dead null check (?? '')
                  content: Text('Pendaftaran ${item.nama} dihapus'),
                ),
              );
              _refresh();
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gagal menghapus data')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : FutureBuilder<List<PenerimaanWarga>>(
              future: _futureList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Gagal memuat data'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('Tidak ada data penerimaan warga')),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12.0,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: ListTile(
                            // Fixed: Removed dead null checks
                            title: Text(item.nama),
                            subtitle: Text(item.email),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) {
                                switch (action) {
                                  case 'Detail':
                                    _openDetail(item);
                                    break;
                                  case 'Edit':
                                    _openEdit(item);
                                    break;
                                  case 'Hapus':
                                    _confirmDelete(item);
                                    break;
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'Detail',
                                  child: Text('Detail'),
                                ),
                                PopupMenuItem(
                                  value: 'Edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'Hapus',
                                  child: Text('Hapus'),
                                ),
                              ],
                            ),
                            onTap: () => _openDetail(item),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

// ---------------------------
// Detail Page (mengunakan model PenerimaanWarga)
// ---------------------------
class DetailPenerimaanPage extends StatelessWidget {
  final PenerimaanWarga item;
  const DetailPenerimaanPage({super.key, required this.item});

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileImage =
        (item.fotoIdentitasUrl != null && item.fotoIdentitasUrl!.isNotEmpty)
        ? NetworkImage(item.fotoIdentitasUrl!)
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Detail Pendaftaran', style: TextStyle(fontSize: 16)),
        titleSpacing: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  'Detail Pendaftaran Warga',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: profileImage as ImageProvider<Object>?,
                      child: profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.blue.shade700,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fixed: Removed dead null check
                        Text(
                          item.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        // Fixed: Removed dead null check
                        Text(
                          item.email,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Fixed: Removed dead null checks below
                _buildDetailRow('NIK', item.nik),
                _buildDetailRow('Jenis Kelamin', item.jenisKelamin),
                _buildDetailRow('Tanggal Dibuat', item.tanggalDibuat),
                _buildDetailRow(
                  'Status Pendaftaran',
                  item.statusRegistrasi,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Foto Identitas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                    image:
                        (item.fotoIdentitasUrl != null &&
                            item.fotoIdentitasUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(item.fotoIdentitasUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      (item.fotoIdentitasUrl == null ||
                          item.fotoIdentitasUrl!.isEmpty)
                      ? const Center(child: Text('Tidak ada foto'))
                      : null,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------
// Edit / Verifikasi Page
// ---------------------------
class EditPenerimaanWargaPage extends StatefulWidget {
  final PenerimaanWarga item;
  const EditPenerimaanWargaPage({super.key, required this.item});

  @override
  State<EditPenerimaanWargaPage> createState() =>
      _EditPenerimaanWargaPageState();
}

class _EditPenerimaanWargaPageState extends State<EditPenerimaanWargaPage> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();

    // Daftar status valid
    const allowedStatus = ['menunggu', 'diproses', 'diterima', 'ditolak'];

    final status = widget.item.statusRegistrasi;

    // Fixed: Removed dead code and simplified
    if (!allowedStatus.contains(status)) {
      currentStatus = 'menunggu';
    } else {
      currentStatus = status;
    }
  }

  Future<void> save() async {
    // Fixed: Removed dead null check (?? 0)
    final ok = await authService.updateStatusPenerimaan(
      widget.item.id,
      currentStatus,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? "Status diperbarui" : "Gagal update")),
    );

    if (ok) Navigator.pop(context, true);
  }

  Widget field(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(value),
      ),
      const SizedBox(height: 16),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Status")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Fixed: Removed dead null checks
            field("Nama", widget.item.nama),
            field("Email", widget.item.email),
            field("NIK", widget.item.nik),
            field("Jenis Kelamin", widget.item.jenisKelamin),
            field("Status Saat Ini", widget.item.statusRegistrasi),

            // ===========================
            // DROPDOWN FIX
            // ===========================
            DropdownButtonFormField<String>(
              value: currentStatus,
              decoration: const InputDecoration(
                labelText: 'Status Pendaftaran',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'menunggu', child: Text('Menunggu')),
                DropdownMenuItem(value: 'diproses', child: Text('Diproses')),
                DropdownMenuItem(value: 'diterima', child: Text('Diterima')),
                DropdownMenuItem(value: 'ditolak', child: Text('Ditolak')),
              ],
              onChanged: (val) {
                if (val == null) return;
                setState(() => currentStatus = val);
              },
            ),

            const SizedBox(height: 30),
            ElevatedButton(onPressed: save, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}

// ===============================
// DELETE DIALOG
// ===============================
class DeleteConfirmationDialog extends StatelessWidget {
  final PenerimaanWarga item;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Hapus Data"),
      // Fixed: Removed dead null check
      content: Text("Yakin ingin menghapus ${item.nama}?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Hapus"),
        ),
      ],
    );
  }
}