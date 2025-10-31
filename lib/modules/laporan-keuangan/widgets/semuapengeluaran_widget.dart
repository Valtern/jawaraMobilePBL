import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/base_list_card.dart';
import '../models/semuapengeluaran_model.dart';

class PengeluaranCard extends StatelessWidget {
  final PengeluaranModel item;
  final Function(String action) onActionSelected;

  const PengeluaranCard({
    super.key,
    required this.item,
    required this.onActionSelected,
  });

  Widget _buildInfoRow(
    String title,
    String value, {
    Alignment alignment = Alignment.centerLeft,
  }) {
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
              textAlign: (alignment == Alignment.centerRight)
                  ? TextAlign.right
                  : TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseListCard(
      child: InkWell(
        onTap: () => onActionSelected('Detail'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (String result) {
                    onActionSelected(result);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Detail',
                          child: Text('Detail'),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Jenis Pengeluaran',
              item.jenisPengeluaran,
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

class SemuaPengeluaranCardList extends StatelessWidget {
  final List<PengeluaranModel> data;
  final Function(String action, PengeluaranModel item) onCardAction;

  const SemuaPengeluaranCardList({
    super.key,
    required this.data,
    required this.onCardAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: data.length,
      padding: const EdgeInsets.only(top: 8.0),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = data[index];
        return PengeluaranCard(
          item: item,
          onActionSelected: (action) => onCardAction(action, item),
        );
      },
    );
  }
}
