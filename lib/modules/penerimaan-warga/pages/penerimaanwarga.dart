import 'package:flutter/material.dart';
import '../models/penerimaanwarga_model.dart';
import '../widgets/penerimaanwarga_widget.dart';

// --- Dummy Data ---
// URL foto placeholder yang bisa diakses
const String DUMMY_PHOTO_URL_1 = 'https://i.pravatar.cc/150?img=1';
const String DUMMY_PHOTO_URL_2 = 'https://i.pravatar.cc/150?img=5';
const String DUMMY_IDENTITY_URL =
    'https://placehold.co/150x100/A8A8A8/FFF?text=Foto+Identitas';

final List<PenerimaanWarga> dummyDataPenerimaan = [
  const PenerimaanWarga(
    id: 11,
    nama: 'Colette Irwin',
    nik: '1234567891234567',
    email: 'colette@mailinator.com',
    jenisKelamin: 'Laki-laki',
    statusRegistrasi: 'Ditunda',
    tanggalDibuat: '2025-09-29',
    fotoIdentitasUrl: DUMMY_PHOTO_URL_1,
  ),
  const PenerimaanWarga(
    id: 12,
    nama: 'Habibie Ed Dien',
    nik: '2341123456756789',
    email: 'habibie.tki@gmail.com',
    jenisKelamin: 'Laki-laki',
    statusRegistrasi: 'Diterima',
    tanggalDibuat: '2025-09-30',
    fotoIdentitasUrl: DUMMY_PHOTO_URL_2,
  ),
  const PenerimaanWarga(
    id: 13,
    nama: 'Ilham Jaya',
    nik: '2222222222222222',
    email: 'ilham@gmail.com',
    jenisKelamin: 'Perempuan',
    statusRegistrasi: 'Ditolak',
    tanggalDibuat: '2025-10-01',
    fotoIdentitasUrl: null,
  ),
];
// --- End Dummy Data ---

// =================================================================
// 1. DETAIL VIEW (Detail Pendaftaran Warga)
// =================================================================

class DetailPenerimaanPage extends StatelessWidget {
  final PenerimaanWarga item;
  const DetailPenerimaanPage({super.key, required this.item});

  // Helper untuk baris detail
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
          Text(
            value,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // URL foto profil (sama dengan di Card)
    final profileImageProvider =
        item.fotoIdentitasUrl != null && item.fotoIdentitasUrl!.isNotEmpty
        ? NetworkImage(item.fotoIdentitasUrl!)
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Kembali', style: TextStyle(fontSize: 16)),
        titleSpacing: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

                // Foto Profil dan Email/Nama
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage:
                          profileImageProvider as ImageProvider<Object>?,
                      child: profileImageProvider == null
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
                        Text(
                          item.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
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

                // Detail Data
                _buildDetailRow('NIK', item.nik),
                _buildDetailRow('Jenis Kelamin', item.jenisKelamin),
                _buildDetailRow('Tanggal Dibuat', item.tanggalDibuat),
                _buildDetailRow('Status Pendaftaran', item.statusRegistrasi),

                const SizedBox(height: 16),
                const Text(
                  'Foto Identitas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // Mockup Foto Identitas
                Container(
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                    image: item.fotoIdentitasUrl != null
                        ? DecorationImage(
                            image: NetworkImage(
                              DUMMY_IDENTITY_URL,
                            ), // Asumsi ini adalah foto identitas
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.fotoIdentitasUrl == null
                      ? const Center(child: Text("Tidak ada foto"))
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

// =================================================================
// 2. EDIT / VERIFIKASI VIEW (Verifikasi Warga)
// =================================================================

class EditPenerimaanPage extends StatefulWidget {
  final PenerimaanWarga item;
  const EditPenerimaanPage({super.key, required this.item});

  @override
  State<EditPenerimaanPage> createState() => _EditPenerimaanPageState();
}

class _EditPenerimaanPageState extends State<EditPenerimaanPage> {
  late String _statusPendaftaran;

  @override
  void initState() {
    super.initState();
    _statusPendaftaran = widget.item.statusRegistrasi;
  }

  // Widget kustom untuk menampilkan data sebagai TextField non-editable
  Widget _buildNonEditableField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade50,
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Kembali', style: TextStyle(fontSize: 16)),
        titleSpacing: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verifikasi Warga',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Kumpulan Field Detail (mengikuti screenshot)
            _buildNonEditableField('Nama', widget.item.nama),
            _buildNonEditableField('Email', widget.item.email),
            _buildNonEditableField('NIK', widget.item.nik),
            _buildNonEditableField('Jenis Kelamin', widget.item.jenisKelamin),

            // Mockup Foto Identitas KK/KTP
            const Text(
              'Foto Identitas KK/KTP',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              width: 150,
              height: 100,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(DUMMY_IDENTITY_URL),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Status Kepemilikan Rumah (Asumsi data tambahan)
            _buildNonEditableField('Status kepemilikan rumah', 'Pemilik'),

            // --- Kontrol Status Pendaftaran (Edit Field) ---
            const Text(
              'Status Pendaftaran',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _statusPendaftaran,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Diterima', child: Text('Diterima')),
                DropdownMenuItem(value: 'Ditunda', child: Text('Ditunda')),
                DropdownMenuItem(value: 'Ditolak', child: Text('Ditolak')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _statusPendaftaran = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Tombol Aksi (terima dan Tolak/Simpan)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol terima (Hijau)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logika untuk terima dan simpan status
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pendaftaran ${widget.item.nama} Diterima.',
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Terima',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tombol Tolak (Merah)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logika untuk Tolak dan simpan status
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pendaftaran ${widget.item.nama} Ditolak.',
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Tolak',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// 3. HAPUS KONFIRMASI (Konfirmasi Hapus)
// =================================================================

class DeleteConfirmationDialog extends StatelessWidget {
  final PenerimaanWarga item;
  final Function() onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(24.0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Konfirmasi Hapus',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Text(
        'Apakah Anda yakin ingin menghapus data pendaftaran warga "${item.nama}"?',
        style: const TextStyle(fontSize: 16),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

// =================================================================
// Halaman Utama Daftar Penerimaan Warga (Diperbarui Logika Aksi)
// =================================================================

class PenerimaanWargaPage extends StatelessWidget {
  const PenerimaanWargaPage({super.key});

  void _handleAction(
    BuildContext context,
    String action,
    PenerimaanWarga item,
  ) {
    switch (action) {
      case 'Detail':
        // Navigasi ke Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPenerimaanPage(item: item),
          ),
        );
        break;
      case 'Edit':
        // Navigasi ke Edit/Verifikasi
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPenerimaanPage(item: item),
          ),
        );
        break;
      case 'Hapus':
        // Tampilkan dialog konfirmasi hapus
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DeleteConfirmationDialog(
              item: item,
              onConfirm: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pendaftaran ${item.nama} dihapus.')),
                );
                // Logika penghapusan data sebenarnya akan dipanggil di sini.
              },
            );
          },
        );
        break;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const FilterPenerimaanDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              height: 40,
              width: 40,
              child: ElevatedButton(
                onPressed: () => _showFilterDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dummyDataPenerimaan.length,
            itemBuilder: (context, index) {
              final item = dummyDataPenerimaan[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AspirasiCard(
                  item: item,
                  onAction: (action, item) =>
                      _handleAction(context, action, item),
                ),
              );
            },
          ),

          // Pagination (Mock Up)
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: null,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF673AB7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: null,
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Filter Dialog (tetap ada untuk kelengkapan) ---
class FilterPenerimaanDialog extends StatelessWidget {
  const FilterPenerimaanDialog({super.key});

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
            'Filter Penerimaan Warga',
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
            const Text('Jenis Kelamin'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: '-- Pilih Jenis Kelamin --',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
              ],
              onChanged: (String? newValue) {},
            ),
            const SizedBox(height: 24),
            const Text('Status'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: '-- Pilih Status --',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Diterima', child: Text('Diterima')),
                DropdownMenuItem(value: 'Ditunda', child: Text('Ditunda')),
                DropdownMenuItem(value: 'Ditolak', child: Text('Ditolak')),
              ],
              onChanged: (String? newValue) {},
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: <Widget>[
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text(
              'Reset Filter',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
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
            minimumSize: const Size(120, 48),
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
