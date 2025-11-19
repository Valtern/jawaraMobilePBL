import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/services/pemasukan_service.dart';

class TagihanListView extends StatefulWidget {
  const TagihanListView({super.key});

  @override
  State<TagihanListView> createState() => _TagihanListViewState();
}

class _TagihanListViewState extends State<TagihanListView> {
  final PemasukanService _service = PemasukanService();
  String? _filterPaymentStatus; // 'paid' atau 'unpaid'
  String? _filterPeriode;
  List<dynamic> _kategoriIuranList = [];

  String _formatCurrency(num value) => 'Rp ${value.toStringAsFixed(0)}';

  String _paymentStatusLabel(String status) {
    return status == 'paid' ? 'Sudah Dibayar' : 'Belum Dibayar';
  }

  Color _paymentStatusColor(String status) {
    return status == 'paid' ? Colors.green : Colors.orange;
  }

  @override
  void initState() {
    super.initState();
    _loadKategoriIuran();
  }

  Future<void> _loadKategoriIuran() async {
    final list = await _service.getKategoriIuranList();
    if (mounted) {
      setState(() {
        _kategoriIuranList = list;
      });
    }
  }

  void _showAddTagihanSheet(BuildContext context) {
    String? selectedKategoriId;

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
                        'Tagih Iuran',
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
                  label: 'Nama Keluarga',
                  prefixIcon: const Icon(Icons.family_restroom),
                ),
                SelectInput<String>(
                  label: 'Status Keluarga',
                  prefixIcon: const Icon(Icons.verified_user),
                  items: const [
                    DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                    DropdownMenuItem(
                      value: 'Tidak Aktif',
                      child: Text('Tidak Aktif'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                SelectInput<String>(
                  label: 'Jenis Iuran',
                  prefixIcon: const Icon(Icons.category),
                  items: _kategoriIuranList
                      .map((item) {
                        final map = item as Map<String, dynamic>;
                        final id = map['id'];
                        final name = (map['name'] ?? '').toString();
                        if (id == null || name.isEmpty) return null;
                        return DropdownMenuItem<String>(
                          value: id.toString(),
                          child: Text(name),
                        );
                      })
                      .whereType<DropdownMenuItem<String>>()
                      .toList(),
                  value: selectedKategoriId,
                  onChanged: (value) {
                    setState(() {
                      selectedKategoriId = value;
                    });
                  },
                ),
                TextInput(
                  label: 'Kode Tagihan',
                  prefixIcon: const Icon(Icons.qr_code),
                ),
                TextInput(
                  label: 'Nominal',
                  prefixIcon: const Icon(Icons.attach_money),
                  keyboardType: TextInputType.number,
                ),
                TextInput(
                  label: 'Periode Tagihan',
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
                SelectInput<String>(
                  label: 'Status Pembayaran',
                  prefixIcon: const Icon(Icons.payments),
                  items: const [
                    DropdownMenuItem(
                      value: 'Sudah Dibayar',
                      child: Text('Sudah Dibayar'),
                    ),
                    DropdownMenuItem(
                      value: 'Belum Dibayar',
                      child: Text('Belum Dibayar'),
                    ),
                  ],
                  onChanged: (value) {},
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
                            Text('Kirim Tagihan'),
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
    return Stack(
      children: [
        Column(
          spacing: 12,
          children: [
            PageHeader(
              title: 'Daftar Tagihan',
              actions: [
                IconButton(
                  color: Colors.deepPurple,
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        final periodeCtl = TextEditingController(
                          text: _filterPeriode ?? '',
                        );
                        String? statusVal = _filterPaymentStatus;
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              color: Colors.white,
                              child: Column(
                                spacing: 12,
                                children: [
                                  TextInput(
                                    controller: periodeCtl,
                                    label:
                                        'Periode Tagihan (mis. Januari 2024)...',
                                    prefixIcon: const Icon(
                                      Icons.calendar_month,
                                    ),
                                  ),
                                  SelectInput<String>(
                                    label: 'Status Pembayaran',
                                    prefixIcon: const Icon(Icons.payment),
                                    value: statusVal == null
                                        ? null
                                        : (statusVal == 'paid'
                                              ? 'Sudah Dibayar'
                                              : 'Belum Dibayar'),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Sudah Dibayar',
                                        child: Text('Sudah Dibayar'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Belum Dibayar',
                                        child: Text('Belum Dibayar'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setModalState(() {
                                        if (value == 'Sudah Dibayar') {
                                          statusVal = 'paid';
                                        } else if (value == 'Belum Dibayar') {
                                          statusVal = 'unpaid';
                                        } else {
                                          statusVal = null;
                                        }
                                      });
                                    },
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _filterPeriode =
                                                  periodeCtl.text.trim().isEmpty
                                                  ? null
                                                  : periodeCtl.text.trim();
                                              _filterPaymentStatus = statusVal;
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
                                              _filterPeriode = null;
                                              _filterPaymentStatus = null;
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
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _service.getTagihanList(
                  paymentStatus: _filterPaymentStatus,
                  periode: _filterPeriode,
                ),
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
                    return const Center(child: Text('Belum ada tagihan'));
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final id = map['id'] as int?;
                      final keluarga = map['keluarga'];
                      String familyName = '';
                      bool familyActive = true;
                      if (keluarga is Map<String, dynamic>) {
                        familyName =
                            (keluarga['nama_keluarga'] ??
                                    keluarga['name'] ??
                                    '')
                                .toString();
                        final status = (keluarga['status'] ?? '').toString();
                        if (status.isNotEmpty) {
                          familyActive = !status.toLowerCase().contains('non');
                        }
                      }
                      final kategori =
                          (map['kategori_iuran'] ?? map['kategoriIuran']);
                      String kategoriName = '';
                      if (kategori is Map<String, dynamic>) {
                        kategoriName = (kategori['name'] ?? '').toString();
                      }
                      final periode = (map['periode'] ?? '').toString();
                      final nominal = map['nominal'] is num
                          ? map['nominal'] as num
                          : num.tryParse(map['nominal']?.toString() ?? '0') ??
                                0;
                      final paymentStatus = (map['payment_status'] ?? 'unpaid')
                          .toString();
                      return ListTile(
                        isThreeLine: true,
                        leading: Icon(
                          Icons.home,
                          color: familyActive ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          familyName.isEmpty ? 'Keluarga -' : familyName,
                        ),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              [
                                if (kategoriName.isNotEmpty) kategoriName,
                                if (periode.isNotEmpty) periode,
                              ].join(' • '),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(nominal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Chip(
                                    label: Text(
                                      _paymentStatusLabel(paymentStatus),
                                    ),
                                    backgroundColor: _paymentStatusColor(
                                      paymentStatus,
                                    ).withOpacity(0.15),
                                    labelStyle: TextStyle(
                                      color: _paymentStatusColor(paymentStatus),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (id != null) ...[
                                  const SizedBox(width: 4),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        final ok = await _service.deleteTagihan(
                                          id,
                                        );
                                        if (ok) {
                                          if (mounted) {
                                            setState(() {});
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Tagihan berhasil dihapus',
                                                ),
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Gagal menghapus tagihan',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Hapus'),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
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
        Positioned(
          bottom: 0,
          right: 0,
          child: FloatingActionButton(
            heroTag: 'add-tagihan',
            backgroundColor: Colors.deepPurple,
            onPressed: () => _showAddTagihanSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
