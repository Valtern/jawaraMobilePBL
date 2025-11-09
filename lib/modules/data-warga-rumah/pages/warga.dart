import 'package:flutter/material.dart';
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

  void _showAddWargaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final namaController = TextEditingController();
        final nikController = TextEditingController();
        final tempatLahirController = TextEditingController();
        final tanggalLahirController = TextEditingController();
        String? jenisKelamin;
        int? keluargaId;
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
                    TextInput(
                      controller: namaController,
                      label: 'Nama Lengkap',
                      prefixIcon: const Icon(Icons.person),
                    ),
                    TextInput(
                      controller: nikController,
                      label: 'Nomor Induk Kependudukan (NIK)',
                      prefixIcon: const Icon(Icons.badge),
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: _service.getKeluargaList(),
                      builder: (context, snapshot) {
                        final items = snapshot.data ?? [];
                        final dropdownItems = items.map((item) {
                          final map = item as Map<String, dynamic>;
                          final id = map['id'] as int?;
                          final name = (map['nama_keluarga'] ?? map['name'] ?? map['nama'] ?? '').toString();
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(name.isEmpty ? '-' : name),
                          );
                        }).toList();
                        return SelectInput<int>(
                          label: 'Pilih Keluarga (opsional)',
                          prefixIcon: const Icon(Icons.people),
                          value: keluargaId,
                          items: dropdownItems,
                          onChanged: (value) {
                            setModalState(() {
                              keluargaId = value;
                            });
                          },
                        );
                      },
                    ),
                    SelectInput<String>(
                      label: 'Jenis Kelamin',
                      prefixIcon: const Icon(Icons.wc),
                      value: jenisKelamin,
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
                        setModalState(() {
                          jenisKelamin = value;
                        });
                      },
                    ),
                    TextInput(
                      controller: tempatLahirController,
                      label: 'Tempat Lahir',
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                    TextInput(
                      controller: tanggalLahirController,
                      label: 'Tanggal Lahir (YYYY-MM-DD)',
                      prefixIcon: const Icon(Icons.calendar_month),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final nama = namaController.text.trim();
                              final nik = nikController.text.trim();
                              if (nama.isEmpty || nik.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Nama dan NIK wajib diisi')),
                                );
                                return;
                              }
                              final payload = <String, dynamic>{
                                'nama_lengkap': nama,
                                'nik': nik,
                              };
                              if ((jenisKelamin ?? '').isNotEmpty) payload['jenis_kelamin'] = jenisKelamin;
                              if (tempatLahirController.text.trim().isNotEmpty) payload['tempat_lahir'] = tempatLahirController.text.trim();
                              if (tanggalLahirController.text.trim().isNotEmpty) payload['tanggal_lahir'] = tanggalLahirController.text.trim();
                              if (keluargaId != null) payload['keluarga_id'] = keluargaId;

                              final ok = await _service.createWarga(payload);
                              if (ok) {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                  setState(() {}); // refresh list
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    const SnackBar(content: Text('Warga berhasil ditambahkan')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(content: Text('Gagal menambahkan warga')),
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
                                namaController.clear();
                                nikController.clear();
                                tempatLahirController.clear();
                                tanggalLahirController.clear();
                                jenisKelamin = null;
                                keluargaId = null;
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
              title: 'Daftar Warga',
              actions: [
                IconButton(
                  color: Colors.deepPurple,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        final namaCtl = TextEditingController(text: _filterNama ?? '');
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            spacing: 12,
                            children: [
                              TextInput(
                                controller: namaCtl,
                                label: 'Cari berdasarkan nama...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _filterNama = namaCtl.text.trim().isEmpty ? null : namaCtl.text.trim();
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
                                          _filterNama = null;
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
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: service.getWargaList(
                  namaLengkap: _filterNama,
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
                    return const Center(child: Text('Belum ada data warga'));
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final name = (map['nama_lengkap'] ?? map['name'] ?? map['nama'] ?? '').toString();
                      final nik = (map['nik'] ?? '').toString();
                      final keluargaObj = map['keluarga'];
                      String keluargaName = '';
                      if (keluargaObj is Map<String, dynamic>) {
                        keluargaName = (keluargaObj['nama_keluarga'] ?? keluargaObj['name'] ?? keluargaObj['nama'] ?? '').toString();
                      } else {
                        keluargaName = (map['keluarga_name'] ?? map['keluarga'] ?? '').toString();
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
          bottom: 0,
          right: 0,
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
