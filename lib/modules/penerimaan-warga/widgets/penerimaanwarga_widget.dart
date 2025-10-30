import 'package:flutter/material.dart';
import '../models/penerimaanwarga_model.dart'; 

// Aksi Menu (Titik Tiga)
class AspirasiActionMenu extends StatelessWidget {
  final PenerimaanWarga item;
  final Function(String action, PenerimaanWarga item) onActionSelected;

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
          child: Text('Detail'), // Kembali ke 'Detail'
        ),
        const PopupMenuItem<String>(
          value: 'Edit', // Tambahkan 'Edit'
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'Hapus', // Tambahkan 'Hapus'
          child: Text('Hapus'),
        ),
      ],
    );
  }
}

/// A reusable card widget to display Penerimaan Warga details.
class AspirasiCard extends StatelessWidget {
  final PenerimaanWarga item;
  final Function(String action, PenerimaanWarga item) onAction;

  const AspirasiCard({super.key, required this.item, required this.onAction});

  // Helper function untuk menentukan warna status registrasi
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
      case 'Ditunda': 
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

  // Widget Foto Profil/Identitas (ditampilkan di kiri)
  Widget _buildProfileAvatar() {
    final imageProvider = item.fotoIdentitasUrl != null && item.fotoIdentitasUrl!.isNotEmpty
        ? NetworkImage(item.fotoIdentitasUrl!)
        : null;

    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.blue.shade100,
      backgroundImage: imageProvider as ImageProvider<Object>?,
      child: imageProvider == null
          ? Icon(Icons.person, size: 30, color: Colors.blue.shade700)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(item.statusRegistrasi);

    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.statusRegistrasi,
        style: TextStyle(
          color: colors['text'],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final nikText = Text(item.nik, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13));
    final emailText = Text(item.email, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13));
    
    return InkWell(
      onTap: null, // Memastikan Card tidak bisa diklik seluruhnya
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom Foto Profil
            _buildProfileAvatar(),
            const SizedBox(width: 16),
            
            // Kolom Detail Data
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama dan Menu Aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.nama, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                  
                  // NIK:
                  _buildInfoRow('NIK:', nikText), 
                  const SizedBox(height: 4),
                  
                  // Email: 
                  _buildInfoRow('Email:', emailText),
                  const SizedBox(height: 4),
                  
                  // Status Registrasi: 
                  _buildInfoRow('Status Registrasi:', statusBadge), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}