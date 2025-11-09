import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/services/dataWargaRumah_service.dart';

class KeluargaPage extends StatelessWidget {
  const KeluargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(body: KeluargaListView());
  }
}

class KeluargaListView extends StatefulWidget {
  const KeluargaListView({super.key});

  @override
  State<KeluargaListView> createState() => _KeluargaListViewState();
}

class _KeluargaListViewState extends State<KeluargaListView> {
  final DataWargaRumahService _service = DataWargaRumahService();
  String? _filterNamaKeluarga;

  void _showAddKeluargaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final namaKeluargaController = TextEditingController();
        final nomorKkController = TextEditingController();
        int? rumahId;
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
                            'Tambah Data Keluarga',
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
                      controller: namaKeluargaController,
                      label: 'Nama Keluarga',
                      prefixIcon: const Icon(Icons.people),
                    ),
                    TextInput(
                      controller: nomorKkController,
                      label: 'Nomor KK (opsional)',
                      prefixIcon: const Icon(Icons.badge),
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: _service.getRumahList(),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? [];
                        final dropdownItems = items.map((item) {
                          final map = item as Map<String, dynamic>;
                          final id = map['id'] as int?;
                          final alamat = (map['alamat'] ?? map['address'] ?? '').toString();
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(alamat.isEmpty ? '-' : alamat),
                          );
                        }).toList();
                        return SelectInput<int>(
                          label: 'Rumah (opsional)',
                          prefixIcon: const Icon(Icons.home),
                          value: rumahId,
                          items: dropdownItems,
                          onChanged: (value) {
                            setModalState(() {
                              rumahId = value;
                            });
                          },
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final nama = namaKeluargaController.text.trim();
                              if (nama.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Nama Keluarga wajib diisi')),
                                );
                                return;
                              }
                              final payload = <String, dynamic>{
                                'nama_keluarga': nama,
                              };
                              if (nomorKkController.text.trim().isNotEmpty) payload['nomor_kk'] = nomorKkController.text.trim();
                              if (rumahId != null) payload['rumah_id'] = rumahId;

                              final ok = await _service.createKeluarga(payload);
                              if (ok) {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  setState(() {}); // refresh list
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(content: Text('Keluarga berhasil ditambahkan')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(content: Text('Gagal menambahkan keluarga')),
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
                                namaKeluargaController.clear();
                                nomorKkController.clear();
                                rumahId = null;
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
    final service = _service;
    return Stack(
      children: [
        Column(
          spacing: 12,
          children: [
            PageHeader(
              title: 'Daftar Keluarga',
              actions: [
                IconButton(
                  color: Colors.deepPurple,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        final namaCtl = TextEditingController(text: _filterNamaKeluarga ?? '');
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            spacing: 12,
                            children: [
                              TextInput(
                                controller: namaCtl,
                                label: 'Cari berdasarkan nama keluarga...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              SelectInput<String>(
                                label: 'Status Keluarga',
                                prefixIcon: const Icon(Icons.check_circle),
                                items: const [
                                  DropdownMenuItem<String>(
                                    value: 'Aktif',
                                    child: Text('Aktif'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Tidak Aktif',
                                    child: Text('Tidak Aktif'),
                                  ),
                                ],
                                onChanged: (value) {
                                  // Handle filter change
                                },
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _filterNamaKeluarga = namaCtl.text.trim().isEmpty ? null : namaCtl.text.trim();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                                          _filterNamaKeluarga = null;
                                        });
                                        Navigator.of(context).pop();
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
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: service.getKeluargaList(
              namaKeluarga: _filterNamaKeluarga,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('Belum ada data keluarga'));
              }
              return CardListView<dynamic>(
                items: items,
                itemBuilder: (context, item) {
                  final map = item as Map<String, dynamic>;
                  final namaKeluarga = (map['nama_keluarga'] ?? map['name'] ?? map['nama'] ?? '').toString();
                  final nomorKk = (map['nomor_kk'] ?? '').toString();
                  String alamatRumah = '';
                  final rumahObj = map['rumah'];
                  if (rumahObj is Map<String, dynamic>) {
                    alamatRumah = (rumahObj['alamat'] ?? rumahObj['address'] ?? '').toString();
                  }
                  return ListTile(
                    title: Text(namaKeluarga.isEmpty ? '-' : namaKeluarga),
                    subtitle: Text([
                      if (nomorKk.isNotEmpty) 'No.KK: $nomorKk',
                      if (alamatRumah.isNotEmpty) 'Alamat: $alamatRumah',
                    ].join(' • ')),
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: FloatingActionButton(
            onPressed: () => _showAddKeluargaSheet(context),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
