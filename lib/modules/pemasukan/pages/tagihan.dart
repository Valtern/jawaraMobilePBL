import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pemasukan/data/sample_data.dart';
import 'package:jawarapbl/modules/pemasukan/models/tagihan.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/select_input.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';

class TagihanListView extends StatelessWidget {
  const TagihanListView({super.key});

  String _formatCurrency(double value) => 'Rp ${value.toStringAsFixed(0)}';

  String _paymentStatusLabel(PaymentStatus status) {
    return status == PaymentStatus.paid ? 'Sudah Dibayar' : 'Belum Dibayar';
  }

  Color _paymentStatusColor(PaymentStatus status) {
    return status == PaymentStatus.paid ? Colors.green : Colors.orange;
  }

  void _showAddTagihanSheet(BuildContext context) {
    final kategoriItems = PemasukanSamples.kategoriIuranList
        .map(
          (kategori) => DropdownMenuItem<String>(
            value: kategori.name,
            child: Text(kategori.name),
          ),
        )
        .toList();

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
                    DropdownMenuItem(
                      value: 'Aktif',
                      child: Text('Aktif'),
                    ),
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
                  items: kategoriItems,
                  onChanged: (value) {},
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
    final tagihanList = PemasukanSamples.tagihanList;

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
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            spacing: 12,
                            children: [
                              TextInput(
                                label: 'Cari nama keluarga...',
                                prefixIcon: const Icon(Icons.search),
                              ),
                              SelectInput<String>(
                                label: 'Status Pembayaran',
                                prefixIcon: const Icon(Icons.payment),
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
              child: CardListView<Tagihan>(
                shrinkWrap: false,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                items: tagihanList,
                itemBuilder: (context, tagihan) {
                  return ListTile(
                    isThreeLine: true,
                    leading: Icon(
                      Icons.home,
                      color: tagihan.isFamilyActive ? Colors.green : Colors.red,
                    ),
                    title: Text(tagihan.familyName),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${tagihan.iuran.name} • ${tagihan.periode}'),
                        Text('Kode Tagihan: ${tagihan.code}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(tagihan.nominal),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Chip(
                            label: Text(_paymentStatusLabel(tagihan.paymentStatus)),
                            backgroundColor: _paymentStatusColor(
                              tagihan.paymentStatus,
                            ).withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: _paymentStatusColor(tagihan.paymentStatus),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
