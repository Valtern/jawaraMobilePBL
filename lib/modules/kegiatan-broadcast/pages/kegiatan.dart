import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/shared/widgets/add_data_popup.dart';
import 'package:jawarapbl/services/kegiatanBroadcast_service.dart';
import 'package:jawarapbl/services/auth_services.dart';

class KegiatanListView extends StatefulWidget {
  const KegiatanListView({super.key});

  @override
  State<KegiatanListView> createState() => _KegiatanListViewState();
}

class _KegiatanListViewState extends State<KegiatanListView> {
  final KegiatanBroadcastService _service = KegiatanBroadcastService();
  final AuthService _authService = AuthService();
  String? _role;

  String? _filterName;
  String? _filterCategory;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  void _fetchData() {
    setState(() {});
  }

  Future<void> _loadUserRole() async {
    final role = await _authService.getRole();
    if (mounted) {
      setState(() {
        _role = role;
      });
    }
  }

  void _showAddKegiatanSheet(BuildContext context) {
    final nameCtl = TextEditingController();
    final personCtl = TextEditingController();
    final dateCtl = TextEditingController();
    final descCtl = TextEditingController();
    String? categoryVal;
    bool isLoading = false;

    showAddDataPopup(
      context: context,
      title: 'Tambah Kegiatan',
      onSave: () async {
        final name = nameCtl.text.trim();
        final person = personCtl.text.trim();
        final date = dateCtl.text.trim();
        final desc = descCtl.text.trim();

        if (name.isEmpty ||
            person.isEmpty ||
            date.isEmpty ||
            categoryVal == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Nama kegiatan, penanggung jawab, tanggal, dan kategori wajib diisi'),
            ),
          );
          return;
        }

        setState(() => isLoading = true);
        Navigator.of(context).pop();

        final ok = await _service.createKegiatan({
          'name': name,
          'category': categoryVal,
          'person_in_charge': person,
          'event_date': date,
          'description': desc,
        });

        if (ok) {
          if (mounted) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kegiatan berhasil ditambahkan')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal menambahkan kegiatan')),
            );
          }
        }
      },
      onReset: () {
        nameCtl.clear();
        personCtl.clear();
        dateCtl.clear();
        descCtl.clear();
        categoryVal = null;
      },
      isLoading: isLoading,
      formFields: [
        const SizedBox(height: 8),
        TextInput(
          controller: nameCtl,
          label: 'Nama Kegiatan',
          prefixIcon: const Icon(Icons.event),
        ),
        const SizedBox(height: 16),
        SelectInput<String>(
          label: 'Kategori',
          prefixIcon: const Icon(Icons.category),
          value: categoryVal,
          items: const [
            DropdownMenuItem(value: 'Kebersihan', child: Text('Kebersihan')),
            DropdownMenuItem(value: 'Rapat', child: Text('Rapat')),
            DropdownMenuItem(value: 'Pelatihan', child: Text('Pelatihan')),
          ],
          onChanged: (value) {
            categoryVal = value;
          },
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: personCtl,
          label: 'Penanggung Jawab',
          prefixIcon: const Icon(Icons.person),
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: dateCtl,
          label: 'Tanggal',
          prefixIcon: const Icon(Icons.calendar_today),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              dateCtl.text =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
          },
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: descCtl,
          label: 'Deskripsi',
          prefixIcon: const Icon(Icons.description),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canAdd = ['admin', 'rw', 'rt'].contains(_role);

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
                                              _filterCategory = null;
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
        if (canAdd)
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'add-kegiatan',
              backgroundColor: const Color(0xFF6938EF),
              onPressed: () => _showAddKegiatanSheet(context),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
