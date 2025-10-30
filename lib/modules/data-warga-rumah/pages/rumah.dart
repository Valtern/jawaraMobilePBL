import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/data-warga-rumah/data/sample_data.dart';
import 'package:jawarapbl/modules/data-warga-rumah/models/rumah.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';

class RumahPage extends StatelessWidget {
  const RumahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(body: RumahListView());
  }
}

class RumahListView extends StatelessWidget {
  const RumahListView({super.key});

  void _showAddRumahSheet(BuildContext context) {
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
                        'Tambah Data Rumah',
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
                  label: 'Alamat Rumah',
                  prefixIcon: const Icon(Icons.home),
                ),
                SelectInput<String>(
                  label: 'Status Hunian',
                  prefixIcon: const Icon(Icons.home_work),
                  items: const [
                    DropdownMenuItem(
                      value: 'Dihuni',
                      child: Text('Dihuni'),
                    ),
                    DropdownMenuItem(
                      value: 'Kosong',
                      child: Text('Kosong'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                TextInput(
                  label: 'Penanggung Jawab / Kepala Keluarga',
                  prefixIcon: const Icon(Icons.person),
                ),
                TextInput(
                  label: 'Catatan Tambahan',
                  prefixIcon: const Icon(Icons.notes),
                  maxLines: 3,
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
    final rumahList = DataWargaRumahSamples.rumahList;
    return Stack(
      children: [
        Column(
          spacing: 12,
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
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            spacing: 12,
                            children: [
                              TextInput(
                                label: 'Cari alamat rumah...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              SelectInput<String>(
                                label: 'Status Hunian',
                                prefixIcon: const Icon(Icons.home_work),
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
                                  // Handle filter change
                                },
                              ),
                              const Spacer(),
                              Row(
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
              child: CardListView<Rumah>(
                shrinkWrap: false,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                items: rumahList,
                itemBuilder: (context, rumah) {
                  final penghuni = DataWargaRumahSamples.keluargaList
                      .where((keluarga) => keluarga.rumah == rumah)
                      .map((keluarga) => keluarga.name)
                      .toList();
                  return ListTile(
                    leading: const Icon(Icons.home),
                    title: Text(rumah.address),
                    subtitle: penghuni.isEmpty
                        ? const Text('Belum ada keluarga terdaftar')
                        : Text('Dihuni oleh: ${penghuni.join(', ')}'),
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
            heroTag: 'add-rumah',
            onPressed: () => _showAddRumahSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
