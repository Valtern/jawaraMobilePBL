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

class KeluargaListView extends StatelessWidget {
  const KeluargaListView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DataWargaRumahService();
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
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: service.getKeluargaList(),
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
                  final name = (map['name'] ?? map['nama'] ?? '').toString();
                  final leader = (map['leader'] ?? map['kepala'] ?? map['kepala_keluarga'] ?? '').toString();
                  final address = (map['address'] ?? map['alamat'] ?? '').toString();
                  final isActiveVal = map['is_active'] ?? map['aktif'] ?? map['status'];
                  final isActive = isActiveVal is bool
                      ? isActiveVal
                      : (isActiveVal is String
                          ? (isActiveVal.toLowerCase() == 'aktif' || isActiveVal == '1' || isActiveVal.toLowerCase() == 'true')
                          : false);
                  return ListTile(
                    title: Text(name.isEmpty ? '-' : name),
                    subtitle: Text([
                      if (leader.isNotEmpty) 'Kepala: $leader',
                      if (address.isNotEmpty) 'Alamat: $address',
                    ].join(' • ')),
                    trailing: Chip(
                      label: Text(isActive ? 'Aktif' : 'Tidak Aktif'),
                      backgroundColor: isActive
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
