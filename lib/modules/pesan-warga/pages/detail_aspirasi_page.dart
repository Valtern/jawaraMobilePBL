import 'package:flutter/material.dart';
import '../models/informasiaspirasi_model.dart';

class DetailAspirasiPage extends StatelessWidget {
  final AspirasiWarga item;

  const DetailAspirasiPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = item.status.toLowerCase() == 'diterima'
        ? Colors.green
        : item.status.toLowerCase() == 'ditolak'
            ? Colors.red
            : Colors.orange; 

    final statusBgColor = item.status.toLowerCase() == 'diterima'
        ? Colors.green.shade100
        : item.status.toLowerCase() == 'ditolak'
            ? Colors.red.shade100
            : Colors.orange.shade100;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Aspirasi"),
        backgroundColor: Colors.deepPurpleAccent
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.judul,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(item.pengirim ?? '-'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(item.tanggalDibuat ?? '-'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.flag, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor, 
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status.capitalize(),
                        style: TextStyle(
                          color: statusColor, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1),
                const Text(
                  "Deskripsi:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  item.deskripsi,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension CapExtension on String {
  String capitalize() => isNotEmpty
      ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}'
      : this;
}