import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/base_list_card.dart';

class LogAktivitasCard extends StatelessWidget {
  final String deskripsi;
  final String aktor;
  final String tanggal;

  const LogAktivitasCard({
    super.key,
    required this.deskripsi,
    required this.aktor,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
    return BaseListCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.history, color: Colors.deepPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deskripsi,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Aktor: $aktor",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            tanggal,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
