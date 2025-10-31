import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/base_list_card.dart';

class PenggunaData {
  final String nama;
  final String email;
  final String role;
  final IconData icon;

  const PenggunaData({
    required this.nama,
    required this.email,
    required this.role,
    required this.icon,
  });
}

class PenggunaCard extends StatelessWidget {
  final PenggunaData item;
  const PenggunaCard({super.key, required this.item});

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red.shade700;
      case 'petugas':
        return Colors.blue.shade700;
      case 'warga':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(item.role);

    return BaseListCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: roleColor.withOpacity(0.1),
            child: Icon(item.icon, color: roleColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                Text(
                  item.role,
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              // Handle actions
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'Edit', child: Text('Edit')),
              const PopupMenuItem<String>(value: 'Hapus', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }
}
