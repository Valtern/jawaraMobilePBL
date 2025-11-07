import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/log-aktivitas/widgets/log_aktivitas_card.dart';
import 'package:jawarapbl/services/log_aktivitas_service.dart';
import 'package:jawarapbl/shared/models/log_aktivitas_model.dart';

class LogAktivitasPage extends StatefulWidget {
  const LogAktivitasPage({super.key});

  @override
  State<LogAktivitasPage> createState() => _LogAktivitasPageState();
}

class _LogAktivitasPageState extends State<LogAktivitasPage> {
  final LogAktivitasService _service = LogAktivitasService();
  List<LogAktivitas> _logList = [];
  List<LogAktivitas> _filteredLogList = [];
  List<String> _kategoriList = [];
  bool _isLoading = true;
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final logs = await _service.getLogAktivitas();
    final kategoris = await _service.getKategoriList();
    setState(() {
      _logList = logs;
      _filteredLogList = logs;
      _kategoriList = kategoris;
      _isLoading = false;
    });
  }

  void _applyFilter(String? kategori) {
    setState(() {
      _selectedKategori = kategori;
      if (kategori == null || kategori.isEmpty) {
        _filteredLogList = _logList;
      } else {
        _filteredLogList = _logList.where((log) => log.kategori == kategori).toList();
      }
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter Log Aktivitas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih Kategori:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String?>(
              isExpanded: true,
              value: _selectedKategori,
              hint: const Text('Semua Kategori'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Semua Kategori'),
                ),
                ..._kategoriList.map((k) => DropdownMenuItem<String?>(
                  value: k,
                  child: Text(k),
                )),
              ],
              onChanged: (value) {
                Navigator.of(ctx).pop();
                _applyFilter(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Log Aktivitas'),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        titleTextStyle: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header dan filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Log Aktivitas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text("Filter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Daftar aktivitas dalam bentuk card
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredLogList.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada log aktivitas',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchData,
                          child: ListView.separated(
                            itemCount: _filteredLogList.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final log = _filteredLogList[index];
                              return LogAktivitasCard(
                                deskripsi: log.deskripsi,
                                aktor: log.userName,
                                tanggal: log.tanggal,
                                kategori: log.kategori,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
