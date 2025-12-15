import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/shared/widgets/add_data_popup.dart';
import 'package:jawarapbl/services/pemasukan_service.dart';
import 'package:jawarapbl/services/dataWargaRumah_service.dart';

class TagihanListView extends StatefulWidget {
  const TagihanListView({super.key});

  @override
  State<TagihanListView> createState() => _TagihanListViewState();
}

class _TagihanListViewState extends State<TagihanListView> {
  final PemasukanService _service = PemasukanService();
  final DataWargaRumahService _wargaService = DataWargaRumahService();
  String? _filterPaymentStatus; // 'paid' atau 'unpaid'
  String? _filterPeriode;
  List<dynamic> _kategoriIuranList = [];
  List<dynamic> _keluargaList = [];

  void _fetchData() {
    setState(() {});
  }

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
    _loadKeluarga();
  }

  Future<void> _loadKategoriIuran() async {
    final list = await _service.getKategoriIuranList();
    if (mounted) {
      setState(() {
        _kategoriIuranList = list;
      });
    }
  }

  Future<void> _loadKeluarga() async {
    final list = await _wargaService.getKeluargaList();
    if (mounted) {
      setState(() {
        _keluargaList = list;
      });
    }
  }

  void _showAddTagihanSheet(BuildContext context) {
    String? selectedKategoriId;
    String? selectedKeluargaId;
    final nominalCtl = TextEditingController();
    final periodeCtl = TextEditingController();
    String? statusLabel; // 'Sudah Dibayar' / 'Belum Dibayar'

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AddDataPopup(
              title: 'Tagih Iuran',
              saveButtonText: 'Kirim Tagihan',
              isLoading: isLoading,
              onSave: () async {
                if (selectedKeluargaId == null ||
                    selectedKategoriId == null ||
                    (statusLabel ?? '').isEmpty ||
                    nominalCtl.text.trim().isEmpty ||
                    periodeCtl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Keluarga, jenis iuran, nominal, periode, dan status pembayaran wajib diisi',
                      ),
                    ),
                  );
                  return;
                }

                setDialogState(() {
                  isLoading = true;
                });

                final nominal = double.tryParse(nominalCtl.text.trim()) ?? 0;
                final paymentStatus =
                    statusLabel == 'Sudah Dibayar' ? 'paid' : 'unpaid';

                final payload = {
                  'keluarga_id': int.parse(selectedKeluargaId!),
                  'kategori_iuran_id': int.parse(selectedKategoriId!),
                  'nominal': nominal,
                  'periode': periodeCtl.text.trim(),
                  'payment_status': paymentStatus,
                };

                final ok = await _service.createTagihan(payload);

                if (!mounted) return;

                setDialogState(() {
                  isLoading = false;
                });

                if (ok) {
                  Navigator.of(dialogContext).pop();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tagihan berhasil dibuat'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Gagal membuat tagihan. Periksa data dan coba lagi.',
                      ),
                    ),
                  );
                }
              },
              onReset: () {
                setDialogState(() {
                  selectedKeluargaId = null;
                  selectedKategoriId = null;
                  statusLabel = null;
                  nominalCtl.clear();
                  periodeCtl.clear();
                });
              },
              formFields: [
                const SizedBox(height: 8),
                SelectInput<String>(
                  label: 'Nama Keluarga',
                  prefixIcon: const Icon(Icons.family_restroom),
                  value: selectedKeluargaId,
                  items: _keluargaList
                      .map((item) {
                        final map = item as Map<String, dynamic>;
                        final id = map['id'];
                        final name = (map['nama_keluarga'] ?? map['name'] ?? '')
                            .toString();
                        if (id == null || name.isEmpty) return null;
                        return DropdownMenuItem<String>(
                          value: id.toString(),
                          child: Text(name),
                        );
                      })
                      .whereType<DropdownMenuItem<String>>()
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedKeluargaId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
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
                    setDialogState(() {
                      selectedKategoriId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextInput(
                  controller: nominalCtl,
                  label: 'Nominal',
                  prefixIcon: const Icon(Icons.attach_money),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextInput(
                  controller: periodeCtl,
                  label: 'Periode Tagihan',
                  prefixIcon: const Icon(Icons.calendar_month),
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      final y = picked.year.toString().padLeft(4, '0');
                      final m = picked.month.toString().padLeft(2, '0');
                      final d = picked.day.toString().padLeft(2, '0');
                      setDialogState(() {
                        periodeCtl.text = '$y-$m-$d';
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SelectInput<String>(
                  label: 'Status Pembayaran',
                  prefixIcon: const Icon(Icons.payments),
                  value: statusLabel,
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
                    setDialogState(() {
                      statusLabel = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          },
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
                  color: const Color(0xFF6938EF),
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
                                            _fetchData();
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.check, size: 18),
                                              SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'Terapkan',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
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
                                            _fetchData();
                                            Navigator.of(context).pop();
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.refresh, size: 18),
                                              SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'Reset',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
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
                      final int? id = map['id'] is int
                          ? map['id'] as int
                          : int.tryParse(map['id']?.toString() ?? '');

                      final keluarga = map['keluarga'];
                      String familyName = '';
                      bool familyActive = true;
                      if (keluarga is Map<String, dynamic>) {
                        familyName = (keluarga['nama_keluarga'] ??
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
                      final paymentStatus =
                          (map['payment_status'] ?? 'unpaid').toString();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.home,
                              color: familyActive ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    familyName.isEmpty
                                        ? 'Keluarga -'
                                        : familyName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    [
                                      if (kategoriName.isNotEmpty) kategoriName,
                                      if (periode.isNotEmpty) periode,
                                    ].join(' • '),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCurrency(nominal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6938EF),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(
                                    _paymentStatusLabel(paymentStatus),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  backgroundColor: _paymentStatusColor(
                                    paymentStatus,
                                  ).withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color: _paymentStatusColor(paymentStatus),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (id != null)
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
