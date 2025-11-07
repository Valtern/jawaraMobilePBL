import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/base_list_card.dart';

class PenggunaData {
  final int id;
  final String nama;
  final String email;
  final String? nik;
  final String? phone;
  final String role;
  final String status;
  final String? fotoIdentitas;
  final IconData icon;

  const PenggunaData({
    required this.id,
    required this.nama,
    required this.email,
    this.nik,
    this.phone,
    required this.role,
    required this.status,
    this.fotoIdentitas,
    required this.icon,
  });

  factory PenggunaData.fromJson(Map<String, dynamic> json) {
    return PenggunaData(
      id: json['id'],
      nama: json['name'],
      email: json['email'],
      nik: json['nik'],
      phone: json['phone'],
      role: json['role'],
      status: json['status'],
      fotoIdentitas: json['foto_identitas'],
      icon: _iconForRole(json['role']),
    );
  }

  static IconData _iconForRole(String role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'rw':
      case 'rt':
      case 'bendahara':
      case 'sekretaris':
        return Icons.support_agent;
      default:
        return Icons.person;
    }
  }
}

class PenggunaCard extends StatelessWidget {
  final PenggunaData item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const PenggunaCard({super.key, required this.item, this.onEdit, this.onDelete});

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red.shade700;
      case 'rw':
      case 'rt':
      case 'bendahara':
      case 'sekretaris':
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
                  '${item.role} • ${item.status}',
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
              if (value == 'Edit') {
                onEdit?.call();
              } else if (value == 'Hapus') {
                onDelete?.call();
              }
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
