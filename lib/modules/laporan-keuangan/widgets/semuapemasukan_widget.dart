import 'package:flutter/material.dart';
import '../models/semuapemasukan_model.dart';

// Widget Mobile Card untuk Pemasukan
class PemasukanCard extends StatelessWidget {
  // Mengubah onActionTap menjadi onActionSelected(String action) untuk konsistensi
  final PemasukanModel item;
  final Function(String action) onActionSelected; 

  const PemasukanCard({
    super.key,
    required this.item,
    required this.onActionSelected,
  });

  // Helper untuk baris informasi dengan alignment
  Widget _buildInfoRow(String title, String value, {Alignment alignment = Alignment.centerLeft}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: alignment,
            child: Text(
              value,
              textAlign: (alignment == Alignment.centerRight) ? TextAlign.right : TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        // Memicu aksi 'Detail' ketika kartu di-tap
        onTap: () => onActionSelected('Detail'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Judul (NAMA) dan Menu Aksi
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
                // Menu Aksi (Titik Tiga) - HANYA DETAIL
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String result) {
                    onActionSelected(result); // Memicu aksi 'Detail'
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    // HANYA MENYISAKAN MENU DETAIL (sesuai permintaan)
                    const PopupMenuItem<String>(value: 'Detail', child: Text('Detail')), 
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Baris Detail Informasi
            _buildInfoRow(
              'Jenis Pemasukan',
              item.jenisPemasukan,
              alignment: Alignment.centerRight,
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              'Tanggal',
              item.tanggal,
              alignment: Alignment.centerRight,
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              'Nominal',
              item.nominalRupiah,
              alignment: Alignment.centerRight,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget utama yang menampilkan daftar Pemasukan dalam bentuk list card.
class SemuaPemasukanCardList extends StatelessWidget {
  final List<PemasukanModel> data;
  // MENGUBAH onActionTap menjadi onCardAction(String action, PemasukanModel item)
  final Function(String action, PemasukanModel item) onCardAction;

  const SemuaPemasukanCardList({super.key, required this.data, required this.onCardAction});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      padding: const EdgeInsets.only(top: 8.0),
      itemBuilder: (context, index) {
        final item = data[index];
        return PemasukanCard(
          item: item,
          // Meneruskan aksi ke onCardAction di parent widget
          onActionSelected: (action) => onCardAction(action, item), 
        );
      },
    );
  }
}