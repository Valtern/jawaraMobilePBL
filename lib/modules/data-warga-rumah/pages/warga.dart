import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/services/dataWargaRumah_service.dart';

class WargaPage extends StatelessWidget {
  const WargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(body: WargaDaftarView());
  }
}

class WargaDaftarView extends StatefulWidget {
  const WargaDaftarView({super.key});

  @override
  State<WargaDaftarView> createState() => _WargaDaftarViewState();
}

class _WargaDaftarViewState extends State<WargaDaftarView> {
  final DataWargaRumahService _service = DataWargaRumahService();
  String? _filterNama;

  late Future<List<dynamic>> _futureWarga;

  void _fetchData() {
    setState(() {
      _futureWarga = _service.getWargaList(
        namaLengkap: _filterNama,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _showAddWargaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _AddWargaForm(
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
              title: 'Daftar Warga',
              actions: [
                IconButton(
                  color: Colors.deepPurple,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        final namaCtl =
                            TextEditingController(text: _filterNama ?? '');
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            children: [
                              TextInput(
                                controller: namaCtl,
                                label: 'Cari berdasarkan nama...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _filterNama =
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
                                        _filterNama = null;
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
                future: _futureWarga,
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
                    return const Center(child: Text('Belum ada data warga'));
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final name =
                          (map['nama_lengkap'] ??
                                  map['name'] ??
                                  map['nama'] ??
                                  '')
                              .toString();
                      final nik = (map['nik'] ?? '').toString();

                      final keluargaObj = map['keluarga'];
                      String keluargaName = '';
                      if (keluargaObj is Map<String, dynamic>) {
                        keluargaName = (keluargaObj['nama_keluarga'] ??
                                keluargaObj['name'] ??
                                keluargaObj['nama'] ??
                                '')
                            .toString();
                      } else {
                        keluargaName =
                            (map['keluarga_name'] ?? map['keluarga'] ?? '')
                                .toString();
                      }
                      return ListTile(
                        title: Text(name.isEmpty ? '-' : name),
                        subtitle: Text([
                          if (keluargaName.isNotEmpty) keluargaName,
                          if (nik.isNotEmpty) 'NIK - $nik',
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
            backgroundColor: Colors.deepPurple,
            heroTag: 'add-warga',
            onPressed: () => _showAddWargaSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _AddWargaForm extends StatefulWidget {
  final DataWargaRumahService service;
  final VoidCallback onSave;

  const _AddWargaForm({required this.service, required this.onSave});

  @override
  State<_AddWargaForm> createState() => _AddWargaFormState();
}

class _AddWargaFormState extends State<_AddWargaForm> {
  late TextEditingController _namaController;
  late TextEditingController _nikController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _tanggalLahirController;
  String? _jenisKelamin;
  int? _keluargaId;
  bool _isLoading = false;
  DateTime? _selectedTanggalLahir;

  late Future<List<DropdownMenuItem<int>>> _futureKeluargaItems;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _nikController = TextEditingController();
    _tempatLahirController = TextEditingController();
    _tanggalLahirController = TextEditingController();
    _futureKeluargaItems = _fetchKeluargaList();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  Future<List<DropdownMenuItem<int>>> _fetchKeluargaList() async {
    final items = await widget.service.getKeluargaList();
    return items.map((item) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] as int?;
      final name =
          (map['nama_keluarga'] ?? map['name'] ?? map['nama'] ?? '').toString();
      return DropdownMenuItem<int>(
        value: id,
        child: Text(name.isEmpty ? '-' : name),
      );
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggalLahir ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedTanggalLahir) {
      setState(() {
        _selectedTanggalLahir = picked;
        _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final nama = _namaController.text.trim();
    final nik = _nikController.text.trim();
    if (nama.isEmpty || nik.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan NIK wajib diisi')),
      );
      setState(() => _isLoading = false);
      return;
    }
    final payload = <String, dynamic>{
      'nama_lengkap': nama,
      'nik': nik,
    };
    if ((_jenisKelamin ?? '').isNotEmpty) {
      payload['jenis_kelamin'] = _jenisKelamin;
    }
    if (_tempatLahirController.text.trim().isNotEmpty) {
      payload['tempat_lahir'] = _tempatLahirController.text.trim();
    }
    if (_tanggalLahirController.text.trim().isNotEmpty) {
      payload['tanggal_lahir'] = _tanggalLahirController.text.trim();
    }
    if (_keluargaId != null) payload['keluarga_id'] = _keluargaId;

    final error = await widget.service.createWarga(payload);

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
      widget.onSave();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Warga berhasil ditambahkan')),
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
                    'Tambah Data Warga',
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
              controller: _namaController,
              label: 'Nama Lengkap',
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: 12),
            TextInput(
              controller: _nikController,
              label: 'Nomor Induk Kependudukan (NIK)',
              prefixIcon: const Icon(Icons.badge),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<DropdownMenuItem<int>>>(
              future: _futureKeluargaItems,
              builder: (context, snapshot) {
                return SelectInput<int>(
                  label: 'Pilih Keluarga (opsional)',
                  prefixIcon: const Icon(Icons.people),
                  value: _keluargaId,
                  items: snapshot.data ?? [],
                  onChanged: (value) {
                    setState(() {
                      _keluargaId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            SelectInput<String>(
              label: 'Jenis Kelamin',
              prefixIcon: const Icon(Icons.wc),
              value: _jenisKelamin,
              items: const [
                DropdownMenuItem(
                  value: 'Laki-laki',
                  child: Text('Laki-laki'),
                ),
                DropdownMenuItem(
                  value: 'Perempuan',
                  child: Text('Perempuan'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _jenisKelamin = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextInput(
              controller: _tempatLahirController,
              label: 'Tempat Lahir',
              prefixIcon: const Icon(Icons.location_city),
            ),
            const SizedBox(height: 12),
            TextInput(
              controller: _tanggalLahirController,
              label: 'Tanggal Lahir',
              prefixIcon: const Icon(Icons.calendar_month),
              readOnly: true,
              onTap: () => _selectDate(context),
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
                              _namaController.clear();
                              _nikController.clear();
                              _tempatLahirController.clear();
                              _tanggalLahirController.clear();
                              _jenisKelamin = null;
                              _keluargaId = null;
                              _selectedTanggalLahir = null;
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