import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawarapbl/modules/pengeluaran/pages/edit_pengeluaran_page.dart';
import 'package:jawarapbl/modules/pengeluaran/widgets/widgetDaftar.dart';
import 'package:jawarapbl/services/pengeluaran_service.dart';
import 'package:jawarapbl/shared/models/pengeluaran_model.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';

class DaftarPengeluaranPage extends StatefulWidget {
  const DaftarPengeluaranPage({super.key});

  @override
  State<DaftarPengeluaranPage> createState() => DaftarPengeluaranPageState();
}

class DaftarPengeluaranPageState extends State<DaftarPengeluaranPage> {
  final PengeluaranService _service = PengeluaranService();
  late Future<List<Pengeluaran>> _futurePengeluaran;

  Map<String, String> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    setState(() {
      _futurePengeluaran = _service.getPengeluaran(_currentFilters);
    });
  }

  void _onEdit(Pengeluaran item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPengeluaranPage(pengeluaran: item),
      ),
    );

    if (result == true && mounted) {
      refreshData();
    }
  }

  void _onDelete(Pengeluaran item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: Text('Anda yakin ingin menghapus "${item.nama}"?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success =
                  await _service.deletePengeluaran(item.id.toString());
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Berhasil dihapus'),
                        backgroundColor: Colors.green),
                  );
                  refreshData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Gagal menghapus'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _FilterBottomSheet(
          initialFilters: _currentFilters,
          onApply: (newFilters) {
            setState(() {
              _currentFilters = newFilters;
            });
            refreshData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async => refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: [
              PageHeader(
                title: 'Daftar Pengeluaran',
                actions: [
                  IconButton(
                    color: Colors.deepPurple,
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterModal,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Pengeluaran>>(
                future: _futurePengeluaran,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error.toString()}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada data'));
                  }

                  final data = snapshot.data!;
                  return _buildResponsiveLayout(data);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(List<Pengeluaran> data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          int crossAxisCount = (constraints.maxWidth / 350).floor();
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.0,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return PengeluaranCard(
                item: data[index],
                baseUrl: _service.baseUrl,
                service: _service,
                onEdit: () => _onEdit(data[index]),
                onDelete: () => _onDelete(data[index]),
              );
            },
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return PengeluaranCard(
                item: data[index],
                baseUrl: _service.baseUrl,
                service: _service,
                onEdit: () => _onEdit(data[index]),
                onDelete: () => _onDelete(data[index]),
              );
            },
          );
        }
      },
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final Map<String, String> initialFilters;
  final Function(Map<String, String>) onApply;

  const _FilterBottomSheet({
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late TextEditingController _namaController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  String? _selectedKategori;
  bool _caseSensitive = false;

  final List<String> _kategoriItems = [
    'Pemeliharaan Fasilitas',
    'Operasional',
    'Kegiatan',
    'Kebersihan',
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.initialFilters['nama']);
    _startDateController = TextEditingController(text: widget.initialFilters['start_date']);
    _endDateController = TextEditingController(text: widget.initialFilters['end_date']);
    _selectedKategori = widget.initialFilters['kategori'];
    _caseSensitive = widget.initialFilters['case_sensitive'] == 'true';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? initialDate;
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (e) {
        initialDate = DateTime.now();
      }
    }
    
    final now = DateTime.now();
    initialDate = initialDate ?? now;
    if (initialDate.isAfter(now)) {
      initialDate = now;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _onApplyFilters() {
    final Map<String, String> newFilters = {};
    if (_namaController.text.isNotEmpty) {
      newFilters['nama'] = _namaController.text;
    }
    if (_selectedKategori != null) {
      newFilters['kategori'] = _selectedKategori!;
    }
    if (_startDateController.text.isNotEmpty) {
      newFilters['start_date'] = _startDateController.text;
    }
    if (_endDateController.text.isNotEmpty) {
      newFilters['end_date'] = _endDateController.text;
    }
    if (_caseSensitive) {
      newFilters['case_sensitive'] = 'true';
    }

    widget.onApply(newFilters);
    Navigator.pop(context);
  }

  void _onResetFilters() {
    widget.onApply({});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        spacing: 12, 
        children: [
          TextInput(
            label: 'Cari Nama Pengeluaran',
            prefixIcon: const Icon(Icons.search),
            controller: _namaController,
          ),
          SelectInput<String>(
            label: 'Jenis Pengeluaran',
            prefixIcon: const Icon(Icons.category),
            value: _selectedKategori,
            items: _kategoriItems.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedKategori = value;
              });
            },
          ),
          TextFormField(
            controller: _startDateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Tanggal Mulai',
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _startDateController.clear(),
              ),
            ),
            onTap: () => _pickDate(_startDateController),
          ),
          TextFormField(
            controller: _endDateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Tanggal Selesai',
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _endDateController.clear(),
              ),
            ),
            onTap: () => _pickDate(_endDateController),
          ),
          CheckboxListTile(
            title: const Text('Pencarian case-sensitive'),
            value: _caseSensitive,
            onChanged: (bool? value) {
              setState(() {
                _caseSensitive = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const Spacer(), 
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onApplyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check, size: 18),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Terapkan',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _onResetFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh, size: 18),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Reset',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}