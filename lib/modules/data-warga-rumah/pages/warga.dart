import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/data-warga-rumah/data/sample_data.dart';
import 'package:jawarapbl/modules/data-warga-rumah/models/warga.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';

class WargaPage extends StatelessWidget {
  const WargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(body: WargaDaftarView());
  }
}

class WargaDaftarView extends StatelessWidget {
  const WargaDaftarView({super.key});

  void _showAddWargaSheet(BuildContext context) {
    final keluargaItems = DataWargaRumahSamples.keluargaList
        .map(
          (keluarga) => DropdownMenuItem<String>(
            value: keluarga.name,
            child: Text(keluarga.name),
          ),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
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
                  label: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person),
                ),
                TextInput(
                  label: 'Nomor Induk Kependudukan (NIK)',
                  prefixIcon: const Icon(Icons.badge),
                ),
                TextInput(
                  label: 'Nomor HP',
                  prefixIcon: const Icon(Icons.phone),
                ),
                SelectInput<String>(
                  label: 'Pilih Keluarga',
                  prefixIcon: const Icon(Icons.people),
                  items: keluargaItems,
                  onChanged: (value) {},
                ),
                SelectInput<String>(
                  label: 'Jenis Kelamin',
                  prefixIcon: const Icon(Icons.wc),
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
                  onChanged: (value) {},
                ),
                TextInput(
                  label: 'Tempat Lahir',
                  prefixIcon: const Icon(Icons.location_city),
                ),
                TextInput(
                  label: 'Tanggal Lahir',
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
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
                        onPressed: () {},
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
  }

  @override
  Widget build(BuildContext context) {
    final wargaList = DataWargaRumahSamples.wargaList;

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
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            spacing: 12,
                            children: [
                              TextInput(
                                label: 'Cari berdasarkan nama...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              SelectInput<String>(
                                label: 'Pilih Jenis Kelamin',
                                prefixIcon: const Icon(Icons.person),
                                items: const [
                                  DropdownMenuItem<String>(
                                    value: 'Laki-laki',
                                    child: Text('Laki-laki'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Perempuan',
                                    child: Text('Perempuan'),
                                  ),
                                ],
                                onChanged: (value) {
                                  // Handle filter change
                                },
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
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
                                      onPressed: () {},
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
              child: CardListView<Warga>(
                shrinkWrap: false,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                items: wargaList,
                itemBuilder: (context, warga) {
                  return ListTile(
                    title: Text(warga.name),
                    subtitle: Text('${warga.familyName} • NIK - ${warga.nik}'),
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
