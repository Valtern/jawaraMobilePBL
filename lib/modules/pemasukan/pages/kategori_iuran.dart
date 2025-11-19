import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/services/pemasukan_service.dart';

class KategoriIuranListView extends StatefulWidget {
  const KategoriIuranListView({super.key});

  @override
  State<KategoriIuranListView> createState() => _KategoriIuranListViewState();
}

class _KategoriIuranListViewState extends State<KategoriIuranListView> {
  final PemasukanService _service = PemasukanService();
  String? _filterName;
  String? _filterJenis;

  String _formatCurrency(num value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  void _showAddKategoriSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final nameCtl = TextEditingController();
        final nominalCtl = TextEditingController();
        String? jenisVal;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tambah Kategori Iuran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    TextInput(
                      controller: nameCtl,
                      label: 'Nama Kategori',
                      prefixIcon: const Icon(Icons.label),
                    ),
                    SelectInput<String>(
                      label: 'Jenis Iuran',
                      prefixIcon: const Icon(Icons.category),
                      value: jenisVal,
                      items: const [
                        DropdownMenuItem(value: 'Wajib', child: Text('Wajib')),
                        DropdownMenuItem(
                          value: 'Sukarela',
                          child: Text('Sukarela'),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          jenisVal = value;
                        });
                      },
                    ),
                    TextInput(
                      controller: nominalCtl,
                      label: 'Nominal',
                      prefixIcon: const Icon(Icons.attach_money),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = nameCtl.text.trim();
                              final jenis = (jenisVal ?? '').trim();
                              final nominalStr = nominalCtl.text.trim();
                              if (name.isEmpty ||
                                  jenis.isEmpty ||
                                  nominalStr.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Nama, jenis, dan nominal wajib diisi',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final nominal = double.tryParse(nominalStr) ?? 0;
                              final ok = await _service.createKategoriIuran({
                                'name': name,
                                'jenis': jenis,
                                'nominal': nominal,
                              });
                              if (ok) {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  setState(() {});
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Kategori iuran berhasil dibuat',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gagal membuat kategori iuran',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.save),
                                SizedBox(width: 4),
                                Text('Simpan'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                nameCtl.clear();
                                nominalCtl.clear();
                                jenisVal = null;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.refresh),
                                SizedBox(width: 4),
                                Text('Reset'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          spacing: 12,
          children: [
            PageHeader(
              title: 'Kategori Iuran',
              actions: [
                IconButton(
                  color: Colors.deepPurple,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        final nameCtl = TextEditingController(
                          text: _filterName ?? '',
                        );
                        String? jenisVal = _filterJenis;
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              color: Colors.white,
                              child: Column(
                                spacing: 12,
                                children: [
                                  TextInput(
                                    controller: nameCtl,
                                    label: 'Cari kategori iuran...',
                                    prefixIcon: const Icon(Icons.search),
                                  ),
                                  SelectInput<String>(
                                    label: 'Jenis Iuran',
                                    prefixIcon: const Icon(Icons.category),
                                    value: jenisVal,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Wajib',
                                        child: Text('Wajib'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Sukarela',
                                        child: Text('Sukarela'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setModalState(() {
                                        jenisVal = value;
                                      });
                                    },
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _filterName =
                                                  nameCtl.text.trim().isEmpty
                                                  ? null
                                                  : nameCtl.text.trim();
                                              _filterJenis =
                                                  (jenisVal ?? '').isEmpty
                                                  ? null
                                                  : jenisVal;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.check),
                                              SizedBox(width: 4),
                                              Text('Terapkan'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _filterName = null;
                                              _filterJenis = null;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.refresh),
                                              SizedBox(width: 4),
                                              Text('Reset'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _service.getKategoriIuranList(
                  name: _filterName,
                  jenis: _filterJenis,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Gagal memuat data: ${snapshot.error}'),
                    );
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('Belum ada kategori iuran'),
                    );
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final id = map['id'] as int?;
                      final name = (map['name'] ?? '').toString();
                      final jenis = (map['jenis'] ?? '').toString();
                      final nominal = map['nominal'] is num
                          ? map['nominal'] as num
                          : num.tryParse(map['nominal']?.toString() ?? '0') ??
                                0;
                      return ListTile(
                        title: Text(name.isEmpty ? '-' : name),
                        subtitle: Text(
                          '${jenis.isEmpty ? '-' : jenis} • ${_formatCurrency(nominal)}',
                        ),
                        trailing: id == null
                            ? null
                            : PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    final ok = await _service
                                        .deleteKategoriIuran(id);
                                    if (ok) {
                                      if (mounted) {
                                        setState(() {});
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Kategori iuran berhasil dihapus',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gagal menghapus kategori iuran',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Hapus'),
                                  ),
                                ],
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: FloatingActionButton(
            heroTag: 'add-kategori-iuran',
            backgroundColor: Colors.deepPurple,
            onPressed: () => _showAddKategoriSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
