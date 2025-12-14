import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/shared/widgets/add_data_popup.dart';
import 'package:jawarapbl/services/dataWargaRumah_service.dart';

class RumahPage extends StatelessWidget {
  const RumahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(body: RumahListView());
  }
}

class RumahListView extends StatefulWidget {
  const RumahListView({super.key});

  @override
  State<RumahListView> createState() => _RumahListViewState();
}

class _RumahListViewState extends State<RumahListView> {
  final DataWargaRumahService _service = DataWargaRumahService();
  String? _filterAlamat;
  String? _filterStatusHunian;

  late Future<List<dynamic>> _futureRumah;

  void _fetchData() {
    setState(() {
      _futureRumah = _service.getRumahList(
        alamat: _filterAlamat,
        statusHunian: _filterStatusHunian,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _showAddRumahSheet(BuildContext context) {
    final alamatCtl = TextEditingController();
    bool isLoading = false;

    showAddDataPopup(
      context: context,
      title: 'Tambah Data Rumah',
      onSave: () async {
        final alamat = alamatCtl.text.trim();

        if (alamat.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alamat wajib diisi'),
            ),
          );
          return;
        }

        setState(() => isLoading = true);
        Navigator.of(context).pop();

        final ok = await _service.createRumah({
          'alamat': alamat,
          'status_hunian': 'Dihuni',
        });

        if (ok == null) {
          if (mounted) {
            _fetchData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data rumah berhasil ditambahkan')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menambahkan data rumah: $ok')),
            );
          }
        }
      },
      onReset: () {
        alamatCtl.clear();
      },
      isLoading: isLoading,
      formFields: [
        const SizedBox(height: 8),
        TextInput(
          controller: alamatCtl,
          label: 'Alamat',
          prefixIcon: const Icon(Icons.location_on),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        SelectInput<String>(
          label: 'Status Hunian',
          prefixIcon: const Icon(Icons.home_work),
          value: 'Dihuni',
          items: const [
            DropdownMenuItem(value: 'Dihuni', child: Text('Dihuni')),
            DropdownMenuItem(
                value: 'Tidak Dihuni', child: Text('Tidak Dihuni')),
            DropdownMenuItem(
                value: 'Dalam Perbaikan', child: Text('Dalam Perbaikan')),
          ],
          onChanged: (value) {
            // Status hunian akan tetap 'Dihuni' untuk payload
          },
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
          children: [
            PageHeader(
              title: 'Daftar Rumah',
              actions: [
                IconButton(
                  color: Colors.deepPurple,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        final alamatCtl =
                            TextEditingController(text: _filterAlamat ?? '');
                        String? statusVal = _filterStatusHunian;
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  TextInput(
                                    controller: alamatCtl,
                                    label: 'Cari alamat rumah...',
                                    prefixIcon: const Icon(Icons.search),
                                  ),
                                  const SizedBox(height: 12),
                                  SelectInput<String>(
                                    label: 'Status Hunian',
                                    prefixIcon: const Icon(Icons.home_work),
                                    value: statusVal,
                                    items: const [
                                      DropdownMenuItem<String>(
                                        value: 'Dihuni',
                                        child: Text('Dihuni'),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'Kosong',
                                        child: Text('Kosong'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setModalState(() {
                                        statusVal = value;
                                      });
                                    },
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _filterAlamat =
                                                alamatCtl.text.trim().isEmpty
                                                    ? null
                                                    : alamatCtl.text.trim();
                                            _filterStatusHunian =
                                                (statusVal ?? '').isEmpty
                                                    ? null
                                                    : statusVal;
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
                                            _filterAlamat = null;
                                            _filterStatusHunian = null;
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
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _futureRumah,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Gagal memuat data: ${snapshot.error}'));
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text('Belum ada data rumah'));
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final address =
                          (map['address'] ?? map['alamat'] ?? '').toString();
                      return ListTile(
                        leading: const Icon(Icons.home),
                        title: Text(address.isEmpty ? '-' : address),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            heroTag: 'add-rumah',
            onPressed: () => _showAddRumahSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
