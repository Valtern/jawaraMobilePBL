import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/shared/widgets/add_data_popup.dart';
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
  String? _filterNik;
  int? _filterKeluargaId;
  List<dynamic> _keluargaList = [];

  late Future<List<dynamic>> _futureWarga;

  void _fetchData() {
    setState(() {
      _futureWarga = _service.getWargaList(
        namaLengkap: _filterNama,
        nik: _filterNik,
        keluargaId: _filterKeluargaId,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadKeluargaList();
  }

  Future<void> _loadKeluargaList() async {
    try {
      final keluarga = await _service.getKeluargaList();
      setState(() {
        _keluargaList = keluarga;
      });
    } catch (e) {
      // Handle error silently or show message if needed
    }
  }

  void _showAddWargaSheet(BuildContext context) {
    final namaCtl = TextEditingController();
    final nikCtl = TextEditingController();
    final tempatLahirCtl = TextEditingController();
    final tanggalLahirCtl = TextEditingController();
    final pekerjaanCtl = TextEditingController();
    String? jenisKelamin;
    String? statusPerkawinan;
    int? keluargaId;
    bool isLoading = false;

    showAddDataPopup(
      context: context,
      title: 'Tambah Data Warga',
      onSave: () async {
        final nama = namaCtl.text.trim();
        final nik = nikCtl.text.trim();
        if (nama.isEmpty || nik.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nama dan NIK wajib diisi')),
          );
          return;
        }

        setState(() => isLoading = true);
        Navigator.of(context).pop();

        final payload = <String, dynamic>{
          'nama_lengkap': nama,
          'nik': nik,
        };

        if ((jenisKelamin ?? '').isNotEmpty) {
          payload['jenis_kelamin'] = jenisKelamin;
        }
        if (tempatLahirCtl.text.trim().isNotEmpty) {
          payload['tempat_lahir'] = tempatLahirCtl.text.trim();
        }
        if (tanggalLahirCtl.text.trim().isNotEmpty) {
          payload['tanggal_lahir'] = tanggalLahirCtl.text.trim();
        }
        if (keluargaId != null) payload['keluarga_id'] = keluargaId;
        if (statusPerkawinan != null) {
          payload['status_perkawinan'] = statusPerkawinan;
        }
        if (pekerjaanCtl.text.trim().isNotEmpty) {
          payload['pekerjaan'] = pekerjaanCtl.text.trim();
        }

        final error = await _service.createWarga(payload);

        if (error == null) {
          _fetchData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data warga berhasil ditambahkan')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan data warga: $error')),
          );
        }
      },
      onReset: () {
        namaCtl.clear();
        nikCtl.clear();
        tempatLahirCtl.clear();
        tanggalLahirCtl.clear();
        pekerjaanCtl.clear();
        jenisKelamin = null;
        statusPerkawinan = null;
        keluargaId = null;
      },
      isLoading: isLoading,
      formFields: [
        const SizedBox(height: 8),
        TextInput(
          controller: namaCtl,
          label: 'Nama Lengkap',
          prefixIcon: const Icon(Icons.person),
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: nikCtl,
          label: 'NIK',
          prefixIcon: const Icon(Icons.badge),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<DropdownMenuItem<int>>>(
          future: _service.getKeluargaList().then((items) => items.map((item) {
                final map = item as Map<String, dynamic>;
                final id = map['id'] as int?;
                final name =
                    (map['nama_keluarga'] ?? map['name'] ?? map['nama'] ?? '')
                        .toString();
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(name.isEmpty ? '-' : name),
                );
              }).toList()),
          builder: (context, snapshot) {
            return SelectInput<int>(
              label: 'Keluarga (opsional)',
              prefixIcon: const Icon(Icons.home),
              value: keluargaId,
              items: snapshot.data ?? [],
              onChanged: (value) {
                keluargaId = value;
              },
            );
          },
        ),
        const SizedBox(height: 16),
        SelectInput<String>(
          label: 'Jenis Kelamin',
          prefixIcon: const Icon(Icons.people),
          value: jenisKelamin,
          items: const [
            DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
          ],
          onChanged: (value) {
            jenisKelamin = value;
          },
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: tempatLahirCtl,
          label: 'Tempat Lahir',
          prefixIcon: const Icon(Icons.location_on),
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: tanggalLahirCtl,
          label: 'Tanggal Lahir',
          prefixIcon: const Icon(Icons.calendar_today),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              tanggalLahirCtl.text = DateFormat('yyyy-MM-dd').format(date);
            }
          },
        ),
        const SizedBox(height: 16),
        SelectInput<String>(
          label: 'Status Perkawinan',
          prefixIcon: const Icon(Icons.family_restroom),
          value: statusPerkawinan,
          items: const [
            DropdownMenuItem(value: 'Belum Kawin', child: Text('Belum Kawin')),
            DropdownMenuItem(value: 'Kawin', child: Text('Kawin')),
            DropdownMenuItem(value: 'Cerai Hidup', child: Text('Cerai Hidup')),
            DropdownMenuItem(value: 'Cerai Mati', child: Text('Cerai Mati')),
          ],
          onChanged: (value) {
            statusPerkawinan = value;
          },
        ),
        const SizedBox(height: 16),
        TextInput(
          controller: pekerjaanCtl,
          label: 'Pekerjaan',
          prefixIcon: const Icon(Icons.work),
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
              title: 'Daftar Warga',
              actions: [
                IconButton(
                  color: Colors.deepPurple,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        final namaCtl = TextEditingController(
                          text: _filterNama ?? '',
                        );
                        final nikCtl = TextEditingController(
                          text: _filterNik ?? '',
                        );
                        int? tempKeluargaId = _filterKeluargaId;
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
                              const SizedBox(height: 12),
                              TextInput(
                                controller: nikCtl,
                                label: 'Cari berdasarkan NIK...',
                                prefixIcon: const Icon(Icons.badge),
                              ),
                              const SizedBox(height: 12),
                              SelectInput<int>(
                                label: 'Filter Keluarga (opsional)',
                                prefixIcon: const Icon(Icons.people),
                                value: tempKeluargaId,
                                items: _keluargaList.map((item) {
                                  final map = item as Map<String, dynamic>;
                                  final id = map['id'] as int?;
                                  final name = (map['nama_keluarga'] ??
                                          map['name'] ??
                                          map['nama'] ??
                                          '')
                                      .toString();
                                  return DropdownMenuItem<int>(
                                    value: id,
                                    child: Text(name.isEmpty ? '-' : name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  tempKeluargaId = value;
                                },
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
                                        _filterNik = nikCtl.text.trim().isEmpty
                                            ? null
                                            : nikCtl.text.trim();
                                        _filterKeluargaId = tempKeluargaId;
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
                                        _filterNik = null;
                                        _filterKeluargaId = null;
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
                      child: Text('Gagal memuat data: ${snapshot.error}'),
                    );
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
                      final name = (map['nama_lengkap'] ??
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
                        subtitle: Text(
                          [
                            if (keluargaName.isNotEmpty) keluargaName,
                            if (nik.isNotEmpty) 'NIK - $nik',
                          ].join(' • '),
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
