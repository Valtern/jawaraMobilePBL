import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pesan-warga/models/informasiaspirasi_model.dart';
import 'package:jawarapbl/shared/widgets/base_list_card.dart';
import 'package:jawarapbl/modules/pesan-warga/pages/detail_aspirasi_page.dart';

class AspirasiActionMenu extends StatelessWidget {
  final AspirasiWarga item;
  final bool isOwner;
  final bool isManagement;
  final Function(String action, AspirasiWarga item) onActionSelected;

  const AspirasiActionMenu({
    super.key,
    required this.item,
    required this.isOwner,
    required this.isManagement,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String result) {
        onActionSelected(result, item);
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> menuItems = [];

        menuItems.add(
          const PopupMenuItem<String>(value: 'Detail', child: Text('Detail')),
        );

        if (isOwner) {
          menuItems.add(
            const PopupMenuItem<String>(
                value: 'Edit Konten', child: Text('Edit Konten')),
          );
        }

        if (isManagement) {
          menuItems.add(
            const PopupMenuItem<String>(
                value: 'Ubah Status', child: Text('Ubah Status')),
          );
        }

        menuItems.add(
          const PopupMenuItem<String>(
              value: 'Hapus', child: Text('Hapus', style: TextStyle(color: Colors.red))),
        );

        return menuItems;
      },
    );
  }
}

class AspirasiCard extends StatelessWidget {
  final AspirasiWarga item;
  final bool isOwner;
  final bool isManagement;
  final Function(String action, AspirasiWarga item) onAction;

  const AspirasiCard({
    super.key,
    required this.item,
    required this.isOwner,
    required this.isManagement,
    required this.onAction,
  });

  Map<String, Color?> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return {'bg': Colors.green.shade100, 'text': Colors.green.shade700};
      case 'ditolak':
        return {'bg': Colors.red.shade100, 'text': Colors.red.shade700};
      case 'pending':
        return {'bg': Colors.yellow.shade100, 'text': Colors.orange.shade800};
      default:
        return {'bg': Colors.grey.shade200, 'text': Colors.grey.shade700};
    }
  }

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
        item.status.capitalize(),
        style: TextStyle(
          color: colors['text'],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final pengirimText = Text(
      item.pengirim ?? '-',
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
    );
    final tanggalText = Text(
      item.tanggalDibuat ?? '',
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
    );

    return BaseListCard(
      child: InkWell(
        onTap: () => onAction('Detail', item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isOwner || isManagement)
                  AspirasiActionMenu(
                    item: item,
                    isOwner: isOwner,
                    isManagement: isManagement,
                    onActionSelected: (action, item) => onAction(action, item),
                  )
                else
                  const SizedBox(width: 48, height: 48),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Dibuat oleh:', pengirimText),
            const SizedBox(height: 4),
            _buildInfoRow('Tanggal Dibuat:', tanggalText),
            const SizedBox(height: 4),
            _buildInfoRow('Status:', statusBadge),
          ],
        ),
      ),
    );
  }
}