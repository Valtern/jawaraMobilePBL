import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawarapbl/services/pengeluaran_service.dart';
import 'package:jawarapbl/shared/models/pengeluaran_model.dart';
import 'package:jawarapbl/shared/widgets/base_list_card.dart';

class PengeluaranCard extends StatelessWidget {
  final Pengeluaran item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String baseUrl;
  final PengeluaranService service;

  const PengeluaranCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.baseUrl,
    required this.service,
  });

  void _showBuktiModal(BuildContext context, String imageUrl) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: size.height * 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text(
                    'Bukti: ${item.nama}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InteractiveViewer(
                      panEnabled: false,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 2.0,
                      child: FutureBuilder<Map<String, String>>(
                        future: service.getAuthHeaders(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final headers = snapshot.data;
                          
                          return Image.network(
                            imageUrl,
                            headers: headers, // Pass auth token
                            fit: BoxFit.contain,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (BuildContext context, Object exception,
                                StackTrace? stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error, color: Colors.red),
                                    SizedBox(height: 8),
                                    Text('Gagal memuat gambar'),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    child: const Text('Tutup'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.nama,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Hapus')),
                  ];
                },
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Jenis Pengeluaran:', item.kategori),
          const SizedBox(height: 4),
          _buildInfoRow(
              'Tanggal:', DateFormat('dd MMMM yyyy').format(item.tanggal)),
          const SizedBox(height: 4),
          _buildInfoRow(
              'Nominal:', 'Rp ${NumberFormat.decimalPattern('id').format(item.nominal)}'),
          if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildInfoRow('Deskripsi:', item.deskripsi!),
          ],
          
          if (item.buktiUrl != null && item.buktiUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.image, size: 16),
                label: const Text('Lihat Bukti'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(fontSize: 13),
                ),
                onPressed: () {
                  // Build the new API URL
                  final imageUrl = '$baseUrl/pengeluaran/bukti/${item.buktiUrl}';
                  
                  _showBuktiModal(context, imageUrl);
                },
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
      ],
    );
  }
}