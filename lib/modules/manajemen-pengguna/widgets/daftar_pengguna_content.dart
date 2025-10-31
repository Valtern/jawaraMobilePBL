import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/pages/tambah_pengguna_page.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/widgets/pengguna_card.dart';

class DaftarPenggunaContent extends StatelessWidget {
  const DaftarPenggunaContent({super.key});

  // Dummy data for the list
  final List<PenggunaData> penggunaList = const [
    PenggunaData(
      nama: 'Admin Jawara',
      email: 'admin@mail.com',
      role: 'Admin',
      icon: Icons.admin_panel_settings,
    ),
    PenggunaData(
      nama: 'Petugas A',
      email: 'petugas_a@mail.com',
      role: 'Petugas',
      icon: Icons.support_agent,
    ),
    PenggunaData(
      nama: 'Warga Budi',
      email: 'budi@mail.com',
      role: 'Warga',
      icon: Icons.person,
    ),
    PenggunaData(
      nama: 'Warga Siti',
      email: 'siti@mail.com',
      role: 'Warga',
      icon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Use padding consistent with list
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "Manajemen Pengguna",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // This button is redundant when using tabs, but kept as per original
              // You might want to remove this button later
              ElevatedButton.icon(
                onPressed: () {
                  // This logic is problematic in a tab view.
                  // It's better to just switch tabs.
                  // For now, it pushes a new page as per original code.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TambahPenggunaPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Tambah"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 🔹 Daftar card-based list
          Expanded(
            child: ListView.separated(
              itemCount: penggunaList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = penggunaList[index];
                return PenggunaCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}
