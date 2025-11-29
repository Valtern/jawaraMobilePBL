import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/services/dataWargaRumah_service.dart';

class RumahPage extends StatelessWidget {
  const RumahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(body: RumahListView());
  }
}

class RumahListView extends StatefulWidget {
  const RumahListView({super.key});

  @override
  State<RumahListView> createState() => _RumahListViewState();
}

class _RumahListViewState extends State<RumahListView> {
  final DataWargaRumahService _service = DataWargaRumahService();
  String? _filterAlamat;
  String? _filterStatusHunian;

  late Future<List<dynamic>> _futureRumah;

  void _fetchData() {
    setState(() {
      _futureRumah = _service.getRumahList(
        alamat: _filterAlamat,
        statusHunian: _filterStatusHunian,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _showAddRumahSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _AddRumahForm(
          service: _service,
          onSave: () {
            _fetchData();
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
                        final alamatCtl =
                            TextEditingController(text: _filterAlamat ?? '');
                        String? statusVal = _filterStatusHunian;
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  TextInput(
                                    controller: alamatCtl,
                                    label: 'Cari alamat rumah...',
                                    prefixIcon: const Icon(Icons.search),
                                  ),
                                  const SizedBox(height: 12),
                                  SelectInput<String>(
                                    label: 'Status Hunian',
                                    prefixIcon: const Icon(Icons.home_work),
                                    value: statusVal,
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
                                      setModalState(() {
                                        statusVal = value;
                                      });
                                    },
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _filterAlamat = alamatCtl.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : alamatCtl.text.trim();
                                            _filterStatusHunian =
                                                (statusVal ?? '').isEmpty
                                                    ? null
                                                    : statusVal;
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
                                            _filterAlamat = null;
                                            _filterStatusHunian = null;
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
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _futureRumah,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Gagal memuat data: ${snapshot.error}'));
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text('Belum ada data rumah'));
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final address =
                          (map['address'] ?? map['alamat'] ?? '').toString();
                      return ListTile(
                        leading: const Icon(Icons.home),
                        title: Text(address.isEmpty ? '-' : address),
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
            heroTag: 'add-rumah',
            onPressed: () => _showAddRumahSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _AddRumahForm extends StatefulWidget {
  final DataWargaRumahService service;
  final VoidCallback onSave;

  const _AddRumahForm({required this.service, required this.onSave});

  @override
  State<_AddRumahForm> createState() => _AddRumahFormState();
}

class _AddRumahFormState extends State<_AddRumahForm> {
  late TextEditingController _addressController;
  String? _statusHunian;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final alamat = _addressController.text.trim();
    final status = (_statusHunian ?? '').trim();

    if (alamat.isEmpty || status.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat dan Status Hunian wajib diisi')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final error = await widget.service.createRumah({
      'alamat': alamat,
      'status_hunian': status,
    });

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
      widget.onSave();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rumah berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $error')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 12),
            TextInput(
              controller: _addressController,
              label: 'Alamat Rumah',
              prefixIcon: const Icon(Icons.home),
            ),
            const SizedBox(height: 12),
            SelectInput<String>(
              label: 'Status Hunian',
              prefixIcon: const Icon(Icons.home_work),
              value: _statusHunian,
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
              onChanged: (value) {
                setState(() {
                  _statusHunian = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save),
                        const SizedBox(width: 4),
                        Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _addressController.clear();
                              _statusHunian = null;
                            });
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
  }
}