import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pengeluaran/widgets/widgetDaftar.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';

class DaftarPengeluaranPage extends StatelessWidget {
  const DaftarPengeluaranPage({super.key});

  final List<Pengeluaran> _data = const [
    Pengeluaran(
      id: 1,
      nama: 'adsad',
      jenis: 'Pemeliharaan Fasilitas',
      tanggal: '02 Oktober 2025',
      nominal: 2112.00,
    ),
    Pengeluaran(
      id: 2,
      nama: 'Beli Sapu',
      jenis: 'Operasional',
      tanggal: '05 Oktober 2025',
      nominal: 25000.00,
    ),
    Pengeluaran(
      id: 3,
      nama: 'Bayar Listrik Pos Jaga',
      jenis: 'Operasional',
      tanggal: '10 Oktober 2025',
      nominal: 75000.00,
    ),
    Pengeluaran(
      id: 4,
      nama: 'Konsumsi Rapat Warga',
      jenis: 'Kegiatan',
      tanggal: '15 Oktober 2025',
      nominal: 150000.00,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            PageHeader(
              title: 'Daftar Pengeluaran',
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const TextInput(
                                label: 'Cari nama pengeluaran...',
                                prefixIcon: Icon(Icons.search),
                              ),
                              const SizedBox(height: 12),
                              SelectInput<String>(
                                label: 'Jenis Pengeluaran',
                                prefixIcon: const Icon(Icons.category),
                                items: const [
                                  DropdownMenuItem<String>(
                                    value: 'Pemeliharaan Fasilitas',
                                    child: Text('Pemeliharaan Fasilitas'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Operasional',
                                    child: Text('Operasional'),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: 'Kegiatan',
                                    child: Text('Kegiatan'),
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
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Terapkan'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      child: const Text('Reset'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResponsiveLayout(),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          int crossAxisCount = (constraints.maxWidth / 350).floor();
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: _data.length,
            itemBuilder: (context, index) {
              return PengeluaranCard(item: _data[index]);
            },
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _data.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return PengeluaranCard(item: _data[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {},
            splashRadius: 20,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('1', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {},
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
