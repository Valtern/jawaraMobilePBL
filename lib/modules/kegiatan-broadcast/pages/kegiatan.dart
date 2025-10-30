import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/kegiatan-broadcast/data/sample_data.dart';
import 'package:jawarapbl/modules/kegiatan-broadcast/models/kegiatan.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';

class KegiatanListView extends StatelessWidget {
  const KegiatanListView({super.key});

  void _showAddKegiatanSheet(BuildContext context) {
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
                        'Tambah Kegiatan',
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
                  label: 'Nama Kegiatan',
                  prefixIcon: const Icon(Icons.event),
                ),
                SelectInput<String>(
                  label: 'Kategori',
                  prefixIcon: const Icon(Icons.category),
                  items: const [
                    DropdownMenuItem(
                      value: 'Kebersihan',
                      child: Text('Kebersihan'),
                    ),
                    DropdownMenuItem(
                      value: 'Rapat',
                      child: Text('Rapat'),
                    ),
                    DropdownMenuItem(
                      value: 'Pelatihan',
                      child: Text('Pelatihan'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                TextInput(
                  label: 'Penanggung Jawab',
                  prefixIcon: const Icon(Icons.person),
                ),
                TextInput(
                  label: 'Tanggal Pelaksanaan',
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
    final kegiatanList = KegiatanBroadcastSamples.kegiatanList;

    return Stack(
      children: [
        Column(
          spacing: 12,
          children: [
            PageHeader(
              title: 'Daftar Kegiatan',
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
                                label: 'Cari kegiatan...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              SelectInput<String>(
                                label: 'Kategori',
                                prefixIcon: const Icon(Icons.category),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Kebersihan',
                                    child: Text('Kebersihan'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Rapat',
                                    child: Text('Rapat'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Pelatihan',
                                    child: Text('Pelatihan'),
                                  ),
                                ],
                                onChanged: (value) {},
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
              child: CardListView<Kegiatan>(
                shrinkWrap: false,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                items: kegiatanList,
                itemBuilder: (context, kegiatan) {
                  return ListTile(
                    leading: const Icon(Icons.event, color: Colors.deepPurple),
                    title: Text(kegiatan.name),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${kegiatan.category} • ${kegiatan.eventDate}'),
                        Text('Penanggung Jawab: ${kegiatan.personInCharge}'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
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
            heroTag: 'add-kegiatan',
            backgroundColor: Colors.deepPurple,
            onPressed: () => _showAddKegiatanSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
