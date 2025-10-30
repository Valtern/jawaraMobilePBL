import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/data-warga-rumah/models/keluarga.dart';
import 'package:jawarapbl/modules/data-warga-rumah/data/sample_data.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';

class KeluargaPage extends StatelessWidget {
  const KeluargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(body: KeluargaListView());
  }
}

class KeluargaListView extends StatelessWidget {
  const KeluargaListView({super.key});

  @override
  Widget build(BuildContext context) {
    final keluargaList = DataWargaRumahSamples.keluargaList;
    return Column(
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
                    return Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      color: Colors.white,
                      child: Column(
                        spacing: 12,
                        children: [
                          TextInput(
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
        CardListView<Keluarga>(
          items: keluargaList,
          itemBuilder: (context, keluarga) {
            return ListTile(
              title: Text(keluarga.name),
              subtitle: Text(
                'Kepala: ${keluarga.leader} • Alamat: ${keluarga.address}',
              ),
              trailing: Chip(
                label: Text(keluarga.isActive ? 'Aktif' : 'Tidak Aktif'),
                backgroundColor: keluarga.isActive
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: keluarga.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
