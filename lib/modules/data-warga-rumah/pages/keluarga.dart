import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/shared/widgets/add_data_popup.dart';
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

  late Future<List<dynamic>> _futureKeluarga;

  void _fetchData() {
    setState(() {
      _futureKeluarga = _service.getKeluargaList(
        namaKeluarga: _filterNamaKeluarga,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _showAddKeluargaSheet(BuildContext context) {
    final namaKeluargaCtl = TextEditingController();
    final nomorKkCtl = TextEditingController();
    int? rumahId;
    bool isLoading = false;

    showAddDataPopup(
      context: context,
      title: 'Tambah Data Keluarga',
      onSave: () async {
        final namaKeluarga = namaKeluargaCtl.text.trim();
        final nomorKk = nomorKkCtl.text.trim();

        if (namaKeluarga.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nama keluarga wajib diisi'),
            ),
          );
          return;
        }

        setState(() => isLoading = true);
        Navigator.of(context).pop();

        final ok = await _service.createKeluarga({
          'nama_keluarga': namaKeluarga,
          'nomor_kk': nomorKk.isEmpty ? null : nomorKk,
          'rumah_id': rumahId,
        });

        if (ok == null) {
          _fetchData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data keluarga berhasil ditambahkan')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan data keluarga: $ok')),
          );
        }
      },
      onReset: () {
        namaKeluargaCtl.clear();
        nomorKkCtl.clear();
        rumahId = null;
      },
      isLoading: isLoading,
      formFields: [
        const SizedBox(height: 8),
        TextInput(
          controller: namaKeluargaCtl,
          label: 'Nama Keluarga',
          prefixIcon: const Icon(Icons.people),
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: nomorKkCtl,
          label: 'Nomor KK (opsional)',
          prefixIcon: const Icon(Icons.badge),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<DropdownMenuItem<int>>>(
          future: _service.getRumahList().then((items) => items.map((item) {
                final map = item as Map<String, dynamic>;
                final id = map['id'] as int?;
                final alamat =
                    (map['alamat'] ?? map['address'] ?? '').toString();
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(alamat.isEmpty ? '-' : alamat),
                );
              }).toList()),
          builder: (context, snapshot) {
            return SelectInput<int>(
              label: 'Rumah (opsional)',
              prefixIcon: const Icon(Icons.home),
              value: rumahId,
              items: snapshot.data ?? [],
              onChanged: (value) {
                rumahId = value;
              },
            );
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
              title: 'Daftar Keluarga',
              actions: [
                IconButton(
                  color: Colors.deepPurple,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        final namaCtl = TextEditingController(
                            text: _filterNamaKeluarga ?? '');
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            children: [
                              TextInput(
                                controller: namaCtl,
                                label: 'Cari berdasarkan nama keluarga...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              const SizedBox(height: 12),
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
                                onChanged: (value) {},
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _filterNamaKeluarga =
                                            namaCtl.text.trim().isEmpty
                                                ? null
                                                : namaCtl.text.trim();
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
                                        _filterNamaKeluarga = null;
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
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _futureKeluarga,
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
                    return const Center(child: Text('Belum ada data keluarga'));
                  }
                  return CardListView<dynamic>(
                    items: items,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final namaKeluarga = (map['nama_keluarga'] ??
                              map['name'] ??
                              map['nama'] ??
                              '')
                          .toString();
                      final nomorKk = (map['nomor_kk'] ?? '').toString();
                      String alamatRumah = '';
                      final rumahObj = map['rumah'];
                      if (rumahObj is Map<String, dynamic>) {
                        alamatRumah =
                            (rumahObj['alamat'] ?? rumahObj['address'] ?? '')
                                .toString();
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
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
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
