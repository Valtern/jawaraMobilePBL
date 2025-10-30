import 'package:flutter/material.dart';
// Asumsi import ini benar, jika tidak, ganti dengan import relatif:
// import '../models/informasiaspirasi_model.dart';
import 'package:jawarapbl/modules/pesan-warga/models/informasiaspirasi_model.dart'; 

// Aksi Menu (Titik Tiga)
class AspirasiActionMenu extends StatelessWidget {
  final AspirasiWarga item;
  final Function(String action, AspirasiWarga item) onActionSelected;

  const AspirasiActionMenu({
    super.key,
    required this.item,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String result) {
        onActionSelected(result, item);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Detail',
          child: Text('Detail'),
        ),
        const PopupMenuItem<String>(
          value: 'Edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'Hapus',
          child: Text('Hapus'),
        ),
      ],
    );
  }
}

/// A reusable card widget to display Aspirasi Warga details.
class AspirasiCard extends StatelessWidget {
  final AspirasiWarga item;
  final Function(String action, AspirasiWarga item) onAction;

  const AspirasiCard({super.key, required this.item, required this.onAction});

  // Helper function untuk menentukan warna status
  Map<String, Color?> _getStatusColors(String status) {
    switch (status) {
      case 'Diterima':
        return {
          'bg': Colors.green.shade100,
          'text': Colors.green.shade700,
        };
      case 'Ditolak':
        return {
          'bg': Colors.red.shade100,
          'text': Colors.red.shade700,
        };
      case 'Ditunda': // Digunakan untuk Pending/Ditunda
        return {
          'bg': Colors.yellow.shade100,
          'text': Colors.orange.shade800,
        };
      default:
        return {
          'bg': Colors.grey.shade200,
          'text': Colors.grey.shade700,
        };
    }
  }

  // Helper untuk baris informasi (menerima Widget)
  Widget _buildInfoRow(String title, Widget valueWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        valueWidget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(item.status);

    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.status,
        style: TextStyle(
          color: colors['text'],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Widget Text polos untuk pengirim dan tanggal
    final pengirimText = Text(item.pengirim, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13));
    final tanggalText = Text(item.tanggalDibuat, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13));

    return InkWell(
      // === PERUBAHAN DI SINI ===
      // Hapus onTap: () => onAction('Detail', item),
      // Atur onTap menjadi null atau kosong agar tidak terjadi aksi.
      // Jika Anda hanya ingin efek visual (splash), biarkan InkWell tanpa onTap.
      onTap: null, // Menghilangkan fungsi klik pada seluruh kartu
      // ==========================
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 8.0), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Baris Judul dan Menu Aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.judul,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                // Menu Aksi (Titik Tiga)
                AspirasiActionMenu(
                  item: item,
                  onActionSelected: (action, item) => onAction(action, item),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Dibuat oleh:
            _buildInfoRow('Dibuat oleh:', pengirimText), 
            const SizedBox(height: 4),
            
            // Tanggal Dibuat:
            _buildInfoRow('Tanggal Dibuat:', tanggalText),
            const SizedBox(height: 4),
            
            // Status: (MENGGUNAKAN BADGE BERWARNA)
            _buildInfoRow('Status:', statusBadge), 
          ],
        ),
      ),
    );
  }
}