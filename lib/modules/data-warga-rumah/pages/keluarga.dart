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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _AddKeluargaForm(
          service: _service,
          onSave: () {
            _fetchData();
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
                      final namaKeluarga =
                          (map['nama_keluarga'] ??
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

class _AddKeluargaForm extends StatefulWidget {
  final DataWargaRumahService service;
  final VoidCallback onSave;

  const _AddKeluargaForm({required this.service, required this.onSave});

  @override
  State<_AddKeluargaForm> createState() => _AddKeluargaFormState();
}

class _AddKeluargaFormState extends State<_AddKeluargaForm> {
  late TextEditingController _namaKeluargaController;
  late TextEditingController _nomorKkController;
  int? _rumahId;
  bool _isLoading = false;

  late Future<List<DropdownMenuItem<int>>> _futureRumahItems;

  @override
  void initState() {
    super.initState();
    _namaKeluargaController = TextEditingController();
    _nomorKkController = TextEditingController();
    _futureRumahItems = _fetchRumahList();
  }

  @override
  void dispose() {
    _namaKeluargaController.dispose();
    _nomorKkController.dispose();
    super.dispose();
  }

  Future<List<DropdownMenuItem<int>>> _fetchRumahList() async {
    final items = await widget.service.getRumahList();
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] as int?;
      final alamat = (map['alamat'] ?? map['address'] ?? '').toString();
      return DropdownMenuItem<int>(
        value: id,
        child: Text(alamat.isEmpty ? '-' : alamat),
      );
    }).toList();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final nama = _namaKeluargaController.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama Keluarga wajib diisi')),
      );
      setState(() => _isLoading = false);
      return;
    }
    final payload = <String, dynamic>{
      'nama_keluarga': nama,
    };
    if (_nomorKkController.text.trim().isNotEmpty) {
      payload['nomor_kk'] = _nomorKkController.text.trim();
    }
    if (_rumahId != null) payload['rumah_id'] = _rumahId;

    final error = await widget.service.createKeluarga(payload);

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
      widget.onSave();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keluarga berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $error')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 12),
            TextInput(
              controller: _namaKeluargaController,
              label: 'Nama Keluarga',
              prefixIcon: const Icon(Icons.people),
            ),
            const SizedBox(height: 12),
            TextInput(
              controller: _nomorKkController,
              label: 'Nomor KK (opsional)',
              prefixIcon: const Icon(Icons.badge),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<DropdownMenuItem<int>>>(
              future: _futureRumahItems,
              builder: (context, snapshot) {
                return SelectInput<int>(
                  label: 'Rumah (opsional)',
                  prefixIcon: const Icon(Icons.home),
                  value: _rumahId,
                  items: snapshot.data ?? [],
                  onChanged: (value) {
                    setState(() {
                      _rumahId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save),
                        const SizedBox(width: 4),
                        Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _namaKeluargaController.clear();
                              _nomorKkController.clear();
                              _rumahId = null;
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
  }
}