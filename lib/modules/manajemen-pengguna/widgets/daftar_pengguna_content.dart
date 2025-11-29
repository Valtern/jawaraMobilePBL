import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/pages/edit_pengguna_page.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/widgets/pengguna_card.dart';
import 'package:jawarapbl/services/user_management_service.dart';

class DaftarPenggunaContent extends StatefulWidget {
  const DaftarPenggunaContent({super.key});

  @override
  State<DaftarPenggunaContent> createState() => _DaftarPenggunaContentState();
}

class _DaftarPenggunaContentState extends State<DaftarPenggunaContent> {
  final UserManagementService _service = UserManagementService();
  List<PenggunaData> _penggunaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final usersJson = await _service.getUsers();
    setState(() {
      _penggunaList = usersJson.map((json) => PenggunaData.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  Future<void> _refreshUsers() async {
    setState(() => _isLoading = true);
    await _fetchUsers();
  }

  void _showDeleteConfirmation(PenggunaData user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Apakah Anda yakin ingin menghapus ${user.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await _service.deleteUser(user.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengguna berhasil dihapus')),
                );
                _refreshUsers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal menghapus pengguna')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _penggunaList.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada data pengguna',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshUsers,
                        child: ListView.separated(
                          itemCount: _penggunaList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = _penggunaList[index];
                            return PenggunaCard(
                              item: user,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditPenggunaPage(user: user),
                                  ),
                                ).then((_) => _refreshUsers());
                              },
                              onDelete: () => _showDeleteConfirmation(user),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
