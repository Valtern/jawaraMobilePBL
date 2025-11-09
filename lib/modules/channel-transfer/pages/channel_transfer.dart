import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/data-list/card_list_view.dart';
import 'package:jawarapbl/shared/widgets/inputs/text_input.dart';
import 'package:jawarapbl/shared/widgets/page/header.dart';
import 'package:jawarapbl/services/channelTransfer_service.dart';

class ChannelTransferPage extends StatefulWidget {
  const ChannelTransferPage({super.key});

  @override
  State<ChannelTransferPage> createState() => _ChannelTransferPageState();
}

class _ChannelTransferPageState extends State<ChannelTransferPage> {
  final ChannelTransferService _service = ChannelTransferService();
  String? _filterBankName;
  String? _filterAccountNumber;
  String? _filterAccountName;

  void _showAddChannelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final bankNameCtl = TextEditingController();
        final accountNumberCtl = TextEditingController();
        final accountNameCtl = TextEditingController();
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
                        'Tambah Channel Transfer',
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
                  controller: bankNameCtl,
                  label: 'Nama Bank',
                  prefixIcon: const Icon(Icons.account_balance),
                ),
                TextInput(
                  controller: accountNumberCtl,
                  label: 'Nomor Rekening',
                  prefixIcon: const Icon(Icons.numbers),
                ),
                TextInput(
                  controller: accountNameCtl,
                  label: 'A/N (Nama Pemilik Rekening)',
                  prefixIcon: const Icon(Icons.person),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final bankName = bankNameCtl.text.trim();
                          final accNumber = accountNumberCtl.text.trim();
                          final accName = accountNameCtl.text.trim();
                          if (bankName.isEmpty || accNumber.isEmpty || accName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Semua field wajib diisi')),
                            );
                            return;
                          }
                          final ok = await _service.createChannelTransfer({
                            'bank_name': bankName,
                            'account_number': accNumber,
                            'account_name': accName,
                          });
                          if (ok) {
                            if (mounted) {
                              Navigator.of(context).pop();
                              setState(() {});
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(content: Text('Channel transfer berhasil ditambahkan')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(content: Text('Gagal menambahkan channel transfer')),
                            );
                          }
                        },
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
                        onPressed: () {
                          bankNameCtl.clear();
                          accountNumberCtl.clear();
                          accountNameCtl.clear();
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
    return Stack(
      children: [
        Column(
          spacing: 12,
          children: [
            PageHeader(
              title: 'Channel Transfer',
              actions: [
                IconButton(
                  color: Colors.deepPurple,
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        final bankCtl = TextEditingController(text: _filterBankName ?? '');
                        final accNumCtl = TextEditingController(text: _filterAccountNumber ?? '');
                        final accNameCtl = TextEditingController(text: _filterAccountName ?? '');
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            spacing: 12,
                            children: [
                              TextInput(
                                controller: bankCtl,
                                label: 'Cari nama bank...',
                                prefixIcon: const Icon(Icons.account_balance),
                              ),
                              TextInput(
                                controller: accNumCtl,
                                label: 'Cari nomor rekening...',
                                prefixIcon: const Icon(Icons.numbers),
                              ),
                              TextInput(
                                controller: accNameCtl,
                                label: 'Cari A/N...',
                                prefixIcon: const Icon(Icons.person),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _filterBankName = bankCtl.text.trim().isEmpty ? null : bankCtl.text.trim();
                                          _filterAccountNumber = accNumCtl.text.trim().isEmpty ? null : accNumCtl.text.trim();
                                          _filterAccountName = accNameCtl.text.trim().isEmpty ? null : accNameCtl.text.trim();
                                        });
                                        Navigator.of(context).pop();
                                      },
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
                                      onPressed: () {
                                        setState(() {
                                          _filterBankName = null;
                                          _filterAccountNumber = null;
                                          _filterAccountName = null;
                                        });
                                        Navigator.of(context).pop();
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
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _service.getChannelTransferList(
                  bankName: _filterBankName,
                  accountNumber: _filterAccountNumber,
                  accountName: _filterAccountName,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text('Belum ada channel transfer'));
                  }
                  return CardListView<dynamic>(
                    shrinkWrap: false,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    items: items,
                    itemBuilder: (context, item) {
                      final map = item as Map<String, dynamic>;
                      final bankName = (map['bank_name'] ?? '').toString();
                      final accountNumber = (map['account_number'] ?? '').toString();
                      final accountName = (map['account_name'] ?? '').toString();
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                          child: const Icon(Icons.credit_card, color: Colors.deepPurple),
                        ),
                        title: Text(bankName.isEmpty ? '-' : bankName),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (accountNumber.isNotEmpty) Text(accountNumber),
                            if (accountName.isNotEmpty) Text(accountName),
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
            heroTag: 'add-channel-transfer',
            backgroundColor: Colors.deepPurple,
            onPressed: () => _showAddChannelSheet(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
