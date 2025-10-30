import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pemasukan/data/sample_data.dart';
import 'package:jawarapbl/modules/pemasukan/models/kategori_iuran.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';

class KategoriIuranListView extends StatelessWidget {
  const KategoriIuranListView({super.key});

  String _formatCurrency(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final kategoriIuranList = PemasukanSamples.kategoriIuranList;

    return Column(
      spacing: 12,
      children: [
        PageHeader(
          title: 'Kategori Iuran',
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
                            label: 'Cari kategori iuran...',
                            prefixIcon: const Icon(Icons.search),
                          ),
                          SelectInput<String>(
                            label: 'Jenis Iuran',
                            prefixIcon: const Icon(Icons.category),
                            items: const [
                              DropdownMenuItem(
                                value: 'Wajib',
                                child: Text('Wajib'),
                              ),
                              DropdownMenuItem(
                                value: 'Sukarela',
                                child: Text('Sukarela'),
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
          child: CardListView<KategoriIuran>(
            shrinkWrap: false,
            items: kategoriIuranList,
            itemBuilder: (context, kategori) {
              return ListTile(
                title: Text(kategori.name),
                subtitle:
                    Text('${kategori.jenis} • ${_formatCurrency(kategori.nominal)}'),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          ),
        ),
      ],
    );
  }
}
