import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/kegiatan-broadcast/data/sample_data.dart';
import 'package:jawarapbl/modules/kegiatan-broadcast/models/broadcast.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';

class BroadcastListView extends StatelessWidget {
  const BroadcastListView({super.key});

  void _showAddBroadcastSheet(BuildContext context) {
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
                        'Tambah Broadcast',
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
                  label: 'Judul Pesan',
                  prefixIcon: const Icon(Icons.campaign),
                ),
                TextInput(
                  label: 'Pengirim',
                  prefixIcon: const Icon(Icons.person),
                ),
                TextInput(
                  label: 'Tanggal',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                TextInput(
                  label: 'Isi Pesan',
                  prefixIcon: const Icon(Icons.message),
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
                            Icon(Icons.send),
                            SizedBox(width: 4),
                            Text('Kirim Broadcast'),
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
    final broadcastList = KegiatanBroadcastSamples.broadcastList;

    return Stack(
      children: [
        Column(
          spacing: 12,
          children: [
            PageHeader(
              title: 'Broadcast',
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
                                label: 'Cari broadcast...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              SelectInput<String>(
                                label: 'Pengirim',
                                prefixIcon: const Icon(Icons.person),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Sekretariat RW',
                                    child: Text('Sekretariat RW'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Ketua RT 01',
                                    child: Text('Ketua RT 01'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Admin Jawara Pintar',
                                    child: Text('Admin Jawara Pintar'),
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
              child: CardListView<Broadcast>(
                shrinkWrap: false,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                items: broadcastList,
                itemBuilder: (context, broadcast) {
                  return ListTile(
                    leading: const Icon(Icons.campaign, color: Colors.deepPurple),
                    title: Text(broadcast.title),
                    subtitle: Text('${broadcast.sender} • ${broadcast.date}'),
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
            heroTag: 'add-broadcast',
            backgroundColor: Colors.deepPurple,
            onPressed: () => _showAddBroadcastSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
