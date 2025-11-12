import 'package:flutter/material.dart';
import 'package:jawarapbl/services/pesan_service.dart';
import 'package:jawarapbl/modules/pesan-warga/models/pesan_model.dart';
import 'package:jawarapbl/shared/widgets/base_list_card.dart';

class PesanMasukPage extends StatefulWidget {
  const PesanMasukPage({super.key});

  @override
  State<PesanMasukPage> createState() => _PesanMasukPageState();
}

class _PesanMasukPageState extends State<PesanMasukPage> {
  final PesanService _pesanService = PesanService();
  late Future<List<Pesan>> _futurePesan;

  @override
  void initState() {
    super.initState();
    _loadPesan();
  }

  void _loadPesan() {
    _futurePesan = _pesanService.getInbox();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadPesan();
    });
  }

  void _showDetailPesan(Pesan pesan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pesan.judul),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dari: ${pesan.pengirim}',
                style: const TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(pesan.isi),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pesan>>(
      future: _futurePesan,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada pesan masuk.'));
        }

        final allPesan = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allPesan.length,
            itemBuilder: (context, index) {
              final pesan = allPesan[index];
              return PesanCard(
                pesan: pesan,
                onTap: () => _showDetailPesan(pesan),
              );
            },
          ),
        );
      },
    );
  }
}

class PesanCard extends StatelessWidget {
  final Pesan pesan;
  final VoidCallback onTap;

  const PesanCard({super.key, required this.pesan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: BaseListCard(
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pesan.judul,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Dari: ${pesan.pengirim}',
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              Text(
                pesan.isi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}