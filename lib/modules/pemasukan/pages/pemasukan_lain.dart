import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pemasukan/data/sample_data.dart';
import 'package:jawarapbl/modules/pemasukan/models/pemasukan_lain.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';

class PemasukanLainListView extends StatelessWidget {
  const PemasukanLainListView({super.key});

  String _formatCurrency(double value) => 'Rp ${value.toStringAsFixed(0)}';

  void _showAddPemasukanLainSheet(BuildContext context) {
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
                        'Tambah Pemasukan Lain',
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
                  label: 'Nama Pemasukan',
                  prefixIcon: const Icon(Icons.title),
                ),
                SelectInput<String>(
                  label: 'Jenis Pemasukan',
                  prefixIcon: const Icon(Icons.category_outlined),
                  items: const [
                    DropdownMenuItem(
                      value: 'Donasi',
                      child: Text('Donasi'),
                    ),
                    DropdownMenuItem(
                      value: 'Sponsor',
                      child: Text('Sponsor'),
                    ),
                    DropdownMenuItem(
                      value: 'Penjualan',
                      child: Text('Penjualan'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                TextInput(
                  label: 'Tanggal',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                TextInput(
                  label: 'Nominal',
                  prefixIcon: const Icon(Icons.attach_money),
                  keyboardType: TextInputType.number,
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
    final pemasukanLainList = PemasukanSamples.pemasukanLainList;

    return Stack(
      children: [
        Column(
          spacing: 12,
          children: [
            PageHeader(
              title: 'Pemasukan Lain',
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
                                label: 'Cari pemasukan...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              SelectInput<String>(
                                label: 'Jenis Pemasukan',
                                prefixIcon: const Icon(Icons.category_outlined),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Donasi',
                                    child: Text('Donasi'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Sponsor',
                                    child: Text('Sponsor'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Penjualan',
                                    child: Text('Penjualan'),
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
              child: CardListView<PemasukanLain>(
                shrinkWrap: false,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                items: pemasukanLainList,
                itemBuilder: (context, pemasukan) {
                  return ListTile(
                    leading: const Icon(Icons.attach_money, color: Colors.deepPurple),
                    title: Text(pemasukan.name),
                    subtitle: Text('${pemasukan.jenis} • ${pemasukan.tanggal}'),
                    trailing: Text(
                      _formatCurrency(pemasukan.nominal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
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
            heroTag: 'add-pemasukan-lain',
            backgroundColor: Colors.deepPurple,
            onPressed: () => _showAddPemasukanLainSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
