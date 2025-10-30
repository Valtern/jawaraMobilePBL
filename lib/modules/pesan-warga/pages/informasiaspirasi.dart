import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pesan-warga/models/informasiaspirasi_model.dart';
import 'package:jawarapbl/modules/pesan-warga/widgets/informasiaspirasi_widget.dart'; // Menggunakan AspirasiCard dari sini

// Halaman Detail Aspirasi (Tidak Berubah)
class DetailAspirasiPage extends StatelessWidget {
  final AspirasiWarga item;
  const DetailAspirasiPage({super.key, required this.item});

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
        child: Card(
          elevation: 0, // Card tanpa bayangan
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
                  'Detail Informasi / Aspirasi Warga',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Judul:', item.judul),
                _buildDetailRow(
                  'Deskripsi:',
                  item.deskripsi,
                  isDescription: true,
                ),
                _buildDetailRow('Status:', item.status),
                _buildDetailRow('Dibuat oleh:', item.pengirim),
                _buildDetailRow('Tanggal Dibuat:', item.tanggalDibuat),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isDescription = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
            style: TextStyle(
              fontSize: isDescription ? 16 : 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Halaman Edit Aspirasi (Tidak Berubah)
class EditAspirasiPage extends StatefulWidget {
  final AspirasiWarga item;
  const EditAspirasiPage({super.key, required this.item});

  @override
  State<EditAspirasiPage> createState() => _EditAspirasiPageState();
}

class _EditAspirasiPageState extends State<EditAspirasiPage> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.item.status;
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
                  'Edit Informasi Aspirasi Warga',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Judul Pesan
                const Text('Judul Pesan'),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: widget.item.judul,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi Pesan
                const Text('Deskripsi Pesan'),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: widget.item.deskripsi,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Status
                const Text('Status'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Diterima',
                      child: Text('Diterima'),
                    ),
                    DropdownMenuItem(value: 'Ditunda', child: Text('Ditunda')),
                    DropdownMenuItem(value: 'Ditolak', child: Text('Ditolak')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _status = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Update
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Logika update data
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Aspirasi "${widget.item.judul}" berhasil di-Update ke status $_status',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF673AB7), // Warna ungu
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dialog Filter
class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

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
            'Filter Pesan Warga',
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
            const Text('Judul'),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Cari judul...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
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
      // --- PERUBAHAN DI BAGIAN ACTIONS ---
      actions: <Widget>[
        // Tombol Reset Filter (Berada di kiri, menggunakan OutlinedButton agar lebih rapih)
        // Kita menggunakan Row dan MainAxisAlignment.spaceBetween untuk memisahkan kedua tombol
        SizedBox(
          height: 48, // Menyamakan tinggi dengan tombol 'Terapkan'
          child: OutlinedButton(
            // Mengganti TextButton dengan OutlinedButton (atau bisa tetap TextButton)
            onPressed: () {
              // Logika Reset Filter
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              // Menghilangkan border karena desain Anda di gambar tidak memiliki border yang jelas
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

        // Tombol Terapkan (Berada di kanan)
        ElevatedButton(
          onPressed: () {
            // Logika Terapkan Filter
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Filter Diterapkan')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7), // Warna ungu
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            minimumSize: const Size(
              120,
              48,
            ), // Menentukan ukuran minimum tombol
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

// Halaman Utama Daftar Aspirasi (DIUBAH total)
class AspirasiWargaPage extends StatelessWidget {
  const AspirasiWargaPage({super.key});

  // Data tiruan (mock data) berdasarkan gambar yang Anda berikan
  final List<AspirasiWarga> _data = const [
    AspirasiWarga(
      id: 1,
      pengirim: 'Habibie Ed Dien',
      judul: 'tes',
      status: 'Diterima',
      deskripsi: 'Ini adalah deskripsi aspirasi dari Habibie Ed Dien.',
      tanggalDibuat: '28 September 2025',
    ),
    AspirasiWarga(
      id: 2,
      pengirim: 'Budi Santoso',
      judul: 'Permintaan Penerangan Jalan',
      status: 'Ditunda',
      deskripsi:
          'Mohon dipertimbangkan untuk pemasangan lampu jalan di Blok C.',
      tanggalDibuat: '01 Oktober 2025',
    ),
  ];

  void _handleAction(BuildContext context, String action, AspirasiWarga item) {
    switch (action) {
      case 'Detail':
        // Navigasi ke halaman detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailAspirasiPage(item: item),
          ),
        );
        break;
      case 'Edit':
        // Navigasi ke halaman edit
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditAspirasiPage(item: item)),
        );
        break;
      case 'Hapus':
        // Tampilkan dialog konfirmasi hapus
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content: Text(
                'Apakah Anda yakin ingin menghapus aspirasi "${item.judul}"?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    // Lakukan logika penghapusan data di sini
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Aspirasi "${item.judul}" dihapus'),
                      ),
                    );
                  },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
        break;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const FilterDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tombol Filter
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              height: 40,
              width: 40,
              child: ElevatedButton(
                onPressed: () => _showFilterDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFF673AB7), // Warna ungu
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

          // Daftar Data (Hanya ListView.builder yang memanggil AspirasiCard)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _data.length,
            itemBuilder: (context, index) {
              final item = _data[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                ), // Beri jarak antar Card
                child: AspirasiCard(
                  // MENGGUNAKAN AspirasiCard
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
                onPressed: null, // Dinonaktifkan
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
                  color: const Color(0xFF673AB7), // Warna ungu
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
