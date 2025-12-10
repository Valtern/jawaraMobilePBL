import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/services/kegiatanBroadcast_service.dart';
import 'package:jawarapbl/services/auth_services.dart';

class BroadcastListView extends StatefulWidget {
  const BroadcastListView({super.key});

  @override
  State<BroadcastListView> createState() => _BroadcastListViewState();
}

class _BroadcastListViewState extends State<BroadcastListView> {
  final KegiatanBroadcastService _service = KegiatanBroadcastService();
  final AuthService _authService = AuthService();
  String? _role;
  String? _filterJudul;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _authService.getRole();
    if (mounted) {
      setState(() {
        _role = role;
      });
    }
  }

  void _showAddBroadcastSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final judulCtl = TextEditingController();
        final isiCtl = TextEditingController();
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
                  controller: judulCtl,
                  label: 'Judul Pesan',
                  prefixIcon: const Icon(Icons.campaign),
                ),
                TextInput(
                  controller: isiCtl,
                  label: 'Isi Pesan',
                  prefixIcon: const Icon(Icons.message),
                  maxLines: 3,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final judul = judulCtl.text.trim();
                          final isi = isiCtl.text.trim();
                          if (judul.isEmpty || isi.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Judul dan isi pesan wajib diisi',
                                ),
                              ),
                            );
                            return;
                          }
                          final ok = await _service.createBroadcast({
                            'judul': judul,
                            'isi_pesan': isi,
                          });
                          if (ok) {
                            if (mounted) {
                              Navigator.of(context).pop();
                              setState(() {});
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Broadcast berhasil dikirim'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Gagal mengirim broadcast'),
                              ),
                            );
                          }
                        },
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
                        onPressed: () {
                          judulCtl.clear();
                          isiCtl.clear();
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
  }

  @override
  Widget build(BuildContext context) {
    final bool canAdd = ['admin', 'rw', 'rt'].contains(_role);

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
                        final judulCtl = TextEditingController(
                          text: _filterJudul ?? '',
                        );
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            spacing: 12,
                            children: [
                              TextInput(
                                controller: judulCtl,
                                label: 'Cari broadcast (judul)...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _filterJudul =
                                              judulCtl.text.trim().isEmpty
                                              ? null
                                              : judulCtl.text.trim();
                                        });
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
                                        setState(() {
                                          _filterJudul = null;
                                        });
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
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _service.getBroadcastList(judul: _filterJudul),
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
                    return const Center(child: Text('Belum ada broadcast'));
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final judul = (map['judul'] ?? '').toString();
                      final isi = (map['isi_pesan'] ?? '').toString();
                      final user = map['user'];
                      String pengirim = '';
                      if (user is Map<String, dynamic>) {
                        pengirim = (user['name'] ?? user['email'] ?? '')
                            .toString();
                      }
                      final createdAt = (map['created_at'] ?? '').toString();
                      return ListTile(
                        leading: const Icon(
                          Icons.campaign,
                          color: Colors.deepPurple,
                        ),
                        title: Text(judul.isEmpty ? '-' : judul),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (pengirim.isNotEmpty || createdAt.isNotEmpty)
                              Text(
                                [
                                  if (pengirim.isNotEmpty) pengirim,
                                  if (createdAt.isNotEmpty) createdAt,
                                ].join(' • '),
                              ),
                            if (isi.isNotEmpty)
                              Text(
                                isi,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        if (canAdd)
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