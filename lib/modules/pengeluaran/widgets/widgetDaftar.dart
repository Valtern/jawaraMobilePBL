import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/base_list_card.dart';

class Pengeluaran {
  final int id;
  final String nama;
  final String jenis;
  final String tanggal;
  final double nominal;

  const Pengeluaran({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.tanggal,
    required this.nominal,
  });
}

class PengeluaranCard extends StatelessWidget {
  final Pengeluaran item;

  const PengeluaranCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return BaseListCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.nama,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Jenis Pengeluaran:', item.jenis),
          const SizedBox(height: 4),
          _buildInfoRow('Tanggal:', item.tanggal),
          const SizedBox(height: 4),
          _buildInfoRow('Nominal:', 'Rp ${item.nominal.toStringAsFixed(2)}'),
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
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }
}
