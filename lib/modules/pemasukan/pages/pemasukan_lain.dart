import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/shared/widgets/add_data_popup.dart';
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

  void _fetchData() {
    setState(() {});
  }

  String _formatCurrency(num value) => 'Rp ${value.toStringAsFixed(0)}';

  void _showAddPemasukanLainSheet(BuildContext context) {
    final nameCtl = TextEditingController();
    String? jenisVal;
    final tanggalCtl = TextEditingController();
    final nominalCtl = TextEditingController();
    final ketCtl = TextEditingController();
    bool isLoading = false;

    showAddDataPopup(
      context: context,
      title: 'Tambah Pemasukan Lain',
      onSave: () async {
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
              content: Text('Nama, jenis, tanggal, dan nominal wajib diisi'),
            ),
          );
          return;
        }

        Navigator.of(context).pop();
        setState(() => isLoading = true);

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

        final ok = await _service.createPemasukanLain(payload);

        setState(() => isLoading = false);

        if (ok) {
          if (mounted) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pemasukan lain berhasil dibuat')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal membuat pemasukan lain')),
            );
          }
        }
      },
      onReset: () {
        nameCtl.clear();
        tanggalCtl.clear();
        nominalCtl.clear();
        ketCtl.clear();
        jenisVal = null;
      },
      isLoading: isLoading,
      formFields: [
        const SizedBox(height: 8),
        TextInput(
          controller: nameCtl,
          label: 'Nama Pemasukan',
          prefixIcon: const Icon(Icons.title),
        ),
        const SizedBox(height: 16),
        SelectInput<String>(
          label: 'Jenis Pemasukan',
          prefixIcon: const Icon(Icons.category_outlined),
          value: jenisVal,
          items: const [
            DropdownMenuItem(value: 'Donasi', child: Text('Donasi')),
            DropdownMenuItem(value: 'Sponsor', child: Text('Sponsor')),
            DropdownMenuItem(value: 'Penjualan', child: Text('Penjualan')),
          ],
          onChanged: (value) {
            jenisVal = value;
          },
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: tanggalCtl,
          label: 'Tanggal (YYYY-MM-DD)',
          prefixIcon: const Icon(Icons.calendar_today),
          readOnly: true,
          onTap: () async {
            FocusScope.of(context).unfocus();
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              final y = picked.year.toString().padLeft(4, '0');
              final m = picked.month.toString().padLeft(2, '0');
              final d = picked.day.toString().padLeft(2, '0');
              tanggalCtl.text = '$y-$m-$d';
            }
          },
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: nominalCtl,
          label: 'Nominal',
          prefixIcon: const Icon(Icons.attach_money),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: ketCtl,
          label: 'Keterangan (opsional)',
          prefixIcon: const Icon(Icons.notes),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
      ],
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
                                            _fetchData();
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
                                            _fetchData();
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
