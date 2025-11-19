import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/services/pemasukan_service.dart';

class PemasukanLainListView extends StatefulWidget {
  const PemasukanLainListView({super.key});

  @override
  State<PemasukanLainListView> createState() => _PemasukanLainListViewState();
}

class _PemasukanLainListViewState extends State<PemasukanLainListView> {
  final PemasukanService _service = PemasukanService();
  String? _filterName;
  String? _filterJenis;

  String _formatCurrency(num value) => 'Rp ${value.toStringAsFixed(0)}';

  void _showAddPemasukanLainSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final nameCtl = TextEditingController();
        String? jenisVal;
        final tanggalCtl = TextEditingController();
        final nominalCtl = TextEditingController();
        final ketCtl = TextEditingController();

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
                            'Tambah Pemasukan Lain',
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
                      label: 'Nama Pemasukan',
                      prefixIcon: const Icon(Icons.title),
                    ),
                    SelectInput<String>(
                      label: 'Jenis Pemasukan',
                      prefixIcon: const Icon(Icons.category_outlined),
                      value: jenisVal,
                      items: const [
                        DropdownMenuItem(
                          value: 'Donasi',
                          child: Text('Donasi'),
                        ),
                        DropdownMenuItem(
                          value: 'Sponsor',
                          child: Text('Sponsor'),
                        ),
                        DropdownMenuItem(
                          value: 'Penjualan',
                          child: Text('Penjualan'),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          jenisVal = value;
                        });
                      },
                    ),
                    TextInput(
                      controller: tanggalCtl,
                      label: 'Tanggal (YYYY-MM-DD)',
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    TextInput(
                      controller: nominalCtl,
                      label: 'Nominal',
                      prefixIcon: const Icon(Icons.attach_money),
                      keyboardType: TextInputType.number,
                    ),
                    TextInput(
                      controller: ketCtl,
                      label: 'Keterangan (opsional)',
                      prefixIcon: const Icon(Icons.notes),
                      maxLines: 2,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = nameCtl.text.trim();
                              final jenis = (jenisVal ?? '').trim();
                              final tanggal = tanggalCtl.text.trim();
                              final nominalStr = nominalCtl.text.trim();
                              if (name.isEmpty ||
                                  jenis.isEmpty ||
                                  tanggal.isEmpty ||
                                  nominalStr.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Nama, jenis, tanggal, dan nominal wajib diisi',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final nominal = double.tryParse(nominalStr) ?? 0;
                              final payload = <String, dynamic>{
                                'name': name,
                                'jenis': jenis,
                                'nominal': nominal,
                                'tanggal': tanggal,
                              };
                              if (ketCtl.text.trim().isNotEmpty) {
                                payload['keterangan'] = ketCtl.text.trim();
                              }
                              final ok = await _service.createPemasukanLain(
                                payload,
                              );
                              if (ok) {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  setState(() {});
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pemasukan lain berhasil dibuat',
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Gagal membuat pemasukan lain',
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
                                tanggalCtl.clear();
                                nominalCtl.clear();
                                ketCtl.clear();
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
              title: 'Pemasukan Lain',
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
                                    label: 'Cari pemasukan...',
                                    prefixIcon: const Icon(Icons.search),
                                  ),
                                  SelectInput<String>(
                                    label: 'Jenis Pemasukan',
                                    prefixIcon: const Icon(
                                      Icons.category_outlined,
                                    ),
                                    value: jenisVal,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Donasi',
                                        child: Text('Donasi'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Sponsor',
                                        child: Text('Sponsor'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Penjualan',
                                        child: Text('Penjualan'),
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
                future: _service.getPemasukanLainList(
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
                      child: Text('Belum ada pemasukan lain'),
                    );
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final name = (map['name'] ?? '').toString();
                      final jenis = (map['jenis'] ?? '').toString();
                      final tanggal = (map['tanggal'] ?? '').toString();
                      final nominal = map['nominal'] is num
                          ? map['nominal'] as num
                          : num.tryParse(map['nominal']?.toString() ?? '0') ??
                                0;
                      return ListTile(
                        leading: const Icon(
                          Icons.attach_money,
                          color: Colors.deepPurple,
                        ),
                        title: Text(name.isEmpty ? '-' : name),
                        subtitle: Text(
                          [
                            if (jenis.isNotEmpty) jenis,
                            if (tanggal.isNotEmpty) tanggal,
                          ].join(' • '),
                        ),
                        trailing: Text(
                          _formatCurrency(nominal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
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
            heroTag: 'add-pemasukan-lain',
            backgroundColor: Colors.deepPurple,
            onPressed: () => _showAddPemasukanLainSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
