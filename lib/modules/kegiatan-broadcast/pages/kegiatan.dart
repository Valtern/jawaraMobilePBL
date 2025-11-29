import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/services/kegiatanBroadcast_service.dart';

class KegiatanListView extends StatefulWidget {
  const KegiatanListView({super.key});

  @override
  State<KegiatanListView> createState() => _KegiatanListViewState();
}

class _KegiatanListViewState extends State<KegiatanListView> {
  final KegiatanBroadcastService _service = KegiatanBroadcastService();
  String? _filterName;
  String? _filterCategory;

  void _showAddKegiatanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final nameCtl = TextEditingController();
        final personCtl = TextEditingController();
        final dateCtl = TextEditingController();
        String? categoryVal;
        final descCtl = TextEditingController();

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
                            'Tambah Kegiatan',
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
                      label: 'Nama Kegiatan',
                      prefixIcon: const Icon(Icons.event),
                    ),
                    SelectInput<String>(
                      label: 'Kategori',
                      prefixIcon: const Icon(Icons.category),
                      value: categoryVal,
                      items: const [
                        DropdownMenuItem(
                          value: 'Kebersihan',
                          child: Text('Kebersihan'),
                        ),
                        DropdownMenuItem(value: 'Rapat', child: Text('Rapat')),
                        DropdownMenuItem(
                          value: 'Pelatihan',
                          child: Text('Pelatihan'),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          categoryVal = value;
                        });
                      },
                    ),
                    TextInput(
                      controller: personCtl,
                      label: 'Penanggung Jawab',
                      prefixIcon: const Icon(Icons.person),
                    ),
                    TextInput(
                      controller: dateCtl,
                      label: 'Tanggal Pelaksanaan (YYYY-MM-DD HH:MM:SS)',
                      prefixIcon: const Icon(Icons.calendar_month),
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
                          dateCtl.text = '$y-$m-$d';
                        }
                      },
                    ),
                    TextInput(
                      controller: descCtl,
                      label: 'Deskripsi (opsional)',
                      prefixIcon: const Icon(Icons.description),
                      maxLines: 3,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = nameCtl.text.trim();
                              final person = personCtl.text.trim();
                              final date = dateCtl.text.trim();
                              final cat = (categoryVal ?? '').trim();
                              if (name.isEmpty ||
                                  person.isEmpty ||
                                  date.isEmpty ||
                                  cat.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Nama, kategori, penanggung jawab, dan tanggal wajib diisi',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final payload = <String, dynamic>{
                                'name': name,
                                'category': cat,
                                'person_in_charge': person,
                                'event_date': date,
                              };
                              if (descCtl.text.trim().isNotEmpty) {
                                payload['description'] = descCtl.text.trim();
                              }
                              final ok = await _service.createKegiatan(payload);
                              if (ok) {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  setState(() {});
                                  ScaffoldMessenger.of(
                                    this.context,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Kegiatan berhasil dibuat'),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gagal membuat kegiatan'),
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
                                personCtl.clear();
                                dateCtl.clear();
                                descCtl.clear();
                                categoryVal = null;
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
              title: 'Daftar Kegiatan',
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
                        String? catVal = _filterCategory;
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
                                    label: 'Cari kegiatan...',
                                    prefixIcon: const Icon(Icons.search),
                                  ),
                                  SelectInput<String>(
                                    label: 'Kategori',
                                    prefixIcon: const Icon(Icons.category),
                                    value: catVal,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Kebersihan',
                                        child: Text('Kebersihan'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Rapat',
                                        child: Text('Rapat'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Pelatihan',
                                        child: Text('Pelatihan'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setModalState(() {
                                        catVal = value;
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
                                              _filterCategory =
                                                  (catVal ?? '').isEmpty
                                                  ? null
                                                  : catVal;
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
                                              _filterCategory = null;
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
                future: _service.getKegiatanList(
                  name: _filterName,
                  category: _filterCategory,
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
                    return const Center(child: Text('Belum ada kegiatan'));
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final name = (map['name'] ?? '').toString();
                      final category = (map['category'] ?? '').toString();
                      final person = (map['person_in_charge'] ?? '').toString();
                      final date = (map['event_date'] ?? '').toString();
                      final desc = (map['description'] ?? '').toString();
                      return ListTile(
                        leading: const Icon(
                          Icons.event,
                          color: Colors.deepPurple,
                        ),
                        title: Text(name.isEmpty ? '-' : name),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              [
                                if (category.isNotEmpty) category,
                                if (date.isNotEmpty) date,
                              ].join(' • '),
                            ),
                            if (person.isNotEmpty)
                              Text('Penanggung Jawab: $person'),
                            if (desc.isNotEmpty)
                              Text(
                                desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
            heroTag: 'add-kegiatan',
            backgroundColor: Colors.deepPurple,
            onPressed: () => _showAddKegiatanSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
