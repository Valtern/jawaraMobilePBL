import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:jawarapbl/services/auth_services.dart';
import '../models/informasiaspirasi_model.dart';
import 'detail_aspirasi_page.dart'; // Tambahkan import ini

class AspirasiWargaPage extends StatefulWidget {
  const AspirasiWargaPage({super.key});

  @override
  State<AspirasiWargaPage> createState() => _AspirasiWargaPageState();
}

class _AspirasiWargaPageState extends State<AspirasiWargaPage> {
  late Future<List<AspirasiWarga>> _futureData;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _futureData = _fetchAspirasi();
  }

  // ======================================================================
  // FETCH DATA DARI API LARAVEL
  // ======================================================================
  Future<List<AspirasiWarga>> _fetchAspirasi() async {
    try {
      final response = await http.get(
        Uri.parse('${AuthService().baseUrl}/aspirasi-warga'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await AuthService().getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body is List ? body : body['data'];

        // pastikan hasilnya adalah List<AspirasiWarga>
        final List<AspirasiWarga> hasil = data
            .map((e) => AspirasiWarga.fromJson(e as Map<String, dynamic>))
            .toList();

        return hasil;
      } else {
        throw Exception('Gagal memuat data aspirasi warga');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // ======================================================================
  // FILTER
  // ======================================================================
  List<AspirasiWarga> _applyFilter(List<AspirasiWarga> data) {
    if (_selectedFilter == 'Semua') return data;
    return data
        .where(
          (item) => item.status.toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<String> options = [
          'Semua',
          'Pending',
          'Diterima',
          'Ditolak',
        ];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Status Aspirasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...options.map(
                (opt) => RadioListTile<String>(
                  value: opt,
                  groupValue: _selectedFilter,
                  title: Text(opt),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================================================================
  // UI
  // ======================================================================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.filter_list),
                label: Text(_selectedFilter),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<AspirasiWarga>>(
            future: _futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Terjadi kesalahan: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Belum ada aspirasi.'));
              }

              final filtered = _applyFilter(snapshot.data!);

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada aspirasi dengan status $_selectedFilter.',
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    setState(() => _futureData = _fetchAspirasi()),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailAspirasiPage(item: item),
                            ),
                          );
                        },
                        title: Text(
                          item.judul,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.pengirim ?? '-'}\n${item.tanggalDibuat ?? ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.status.toLowerCase() == 'diterima'
                                ? Colors.green.shade100
                                : item.status.toLowerCase() == 'ditolak'
                                ? Colors.red.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.status.capitalize(),
                            style: TextStyle(
                              color: item.status.toLowerCase() == 'diterima'
                                  ? Colors.green
                                  : item.status.toLowerCase() == 'ditolak'
                                  ? Colors.red
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
