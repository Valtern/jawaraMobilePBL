import 'package:flutter/material.dart';

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

/// A reusable card widget to display expense details.
class PengeluaranCard extends StatelessWidget {
  final Pengeluaran item;

  const PengeluaranCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
