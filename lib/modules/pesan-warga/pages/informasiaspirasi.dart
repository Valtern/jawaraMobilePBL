import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/services/pesan_service.dart';
import 'package:jawarapbl/shared/models/user_model.dart';
import 'package:jawarapbl/modules/pesan-warga/models/informasiaspirasi_model.dart';
import 'package:jawarapbl/modules/pesan-warga/pages/detail_aspirasi_page.dart';
import 'package:jawarapbl/modules/pesan-warga/pages/edit_aspirasi_page.dart';
import 'package:jawarapbl/shared/widgets/page_transitions.dart';
import '../widgets/informasiaspirasi_widget.dart';

class AspirasiWargaPage extends StatefulWidget {
  const AspirasiWargaPage({super.key});

  @override
  State<AspirasiWargaPage> createState() => _AspirasiWargaPageState();
}

class _AspirasiWargaPageState extends State<AspirasiWargaPage> {
  final PesanService _pesanService = PesanService();
  late Future<List<AspirasiWarga>> _futureData;
  String _selectedFilter = 'Semua';

  User? _currentUser;
  bool _isLoadingUser = true;
  bool _isManagement = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoadingUser = true;
      _isManagement = false;
    });
    try {
      _currentUser = await AuthService().getProfile();
      final role = _currentUser?.role;
      if (role == 'admin' || role == 'rw' || role == 'rt') {
        _isManagement = true;
      }
    } catch (e) {
      // Handle error
    }
    setState(() {
      _futureData = _fetchAspirasi();
      _isLoadingUser = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureData = _fetchAspirasi();
    });
  }

  Future<List<AspirasiWarga>> _fetchAspirasi() async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService().baseUrl}/aspirasi-warga'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService().getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final List<AspirasiWarga> hasil = data
            .map((e) => AspirasiWarga.fromJson(e as Map<String, dynamic>))
            .toList();
        return hasil;
      } else {
        throw Exception('Gagal memuat data aspirasi warga');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  void _handleAspirasiAction(String action, AspirasiWarga item) {
    if (action == 'Detail') {
      NavigationHelper.navigateTo(
        context,
        DetailAspirasiPage(item: item),
      );
    }
    if (action == 'Edit Konten') {
      _navigateToEdit(item);
    }
    if (action == 'Ubah Status') {
      _showStatusUpdateDialog(item);
    }
    if (action == 'Hapus') {
      _confirmDelete(item);
    }
  }

  void _navigateToEdit(AspirasiWarga item) async {
    final result = await NavigationHelper.navigateTo(
      context,
      EditAspirasiPage(aspirasi: item),
    );

    if (result != null) {
      _refreshData();
    }
  }

  void _showStatusUpdateDialog(AspirasiWarga item) {
    String selectedStatus = item.status;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ubah Status Aspirasi'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Pending'),
                    value: 'Pending',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Diterima'),
                    value: 'Diterima',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Ditolak'),
                    value: 'Ditolak',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus(item, selectedStatus);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateStatus(AspirasiWarga item, String newStatus) async {
    try {
      await _pesanService.updateAspirasiStatus(
        id: item.id,
        status: newStatus,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Status aspirasi berhasil diperbarui.'),
              backgroundColor: Colors.green),
        );
      }
      _refreshData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDelete(AspirasiWarga item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Aspirasi'),
        content: Text('Anda yakin ingin menghapus aspirasi "${item.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAspirasi(item.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteAspirasi(int id) async {
    try {
      await _pesanService.deleteAspirasi(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aspirasi berhasil dihapus.'),
              backgroundColor: Colors.green),
        );
      }
      _refreshData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  List<AspirasiWarga> _applyFilter(List<AspirasiWarga> data) {
    if (_selectedFilter == 'Semua') return data;

    final selected = _selectedFilter.trim().toLowerCase();

    return data.where((item) {
      final status = item.status.trim().toLowerCase();
      if (status == selected) return true;
      if (selected == 'pending' && status == 'menunggu') return true;
      return false;
    }).toList();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<String> options = [
          'Semua',
          'Pending',
          'Diterima',
          'Ditolak',
        ];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Status Aspirasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...options.map(
                (opt) => RadioListTile<String>(
                  value: opt,
                  groupValue: _selectedFilter,
                  title: Text(opt),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.filter_list),
                label: Text(_selectedFilter),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingUser
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<AspirasiWarga>>(
                  future: _futureData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Terjadi kesalahan: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Belum ada aspirasi.'));
                    }

                    final filtered = _applyFilter(snapshot.data!);

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada aspirasi dengan status $_selectedFilter.',
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isOwner = _currentUser != null &&
                              _currentUser!.wargaId == item.wargaId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: AspirasiCard(
                              item: item,
                              isOwner: isOwner,
                              isManagement: _isManagement,
                              onAction: _handleAspirasiAction,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
