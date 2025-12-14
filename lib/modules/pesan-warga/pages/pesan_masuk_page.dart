import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/pesan-warga/bloc/pesan_bloc.dart'; 
import 'package:jawarapbl/modules/pesan-warga/models/pesan_model.dart';
import 'package:jawarapbl/shared/widgets/base_list_card.dart';

class PesanMasukPage extends StatefulWidget {
  const PesanMasukPage({super.key});

  @override
  State<PesanMasukPage> createState() => _PesanMasukPageState();
}

class _PesanMasukPageState extends State<PesanMasukPage> {
  final PesanBloc _bloc = PesanBloc();

  @override
  void initState() {
    super.initState();
    _bloc.eventSink.add(null);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _bloc.eventSink.add(null);
    await Future.delayed(const Duration(seconds: 1));
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
    return StreamBuilder<List<Pesan>>(
      stream: _bloc.pesanStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } 

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allPesan = snapshot.data!;

        if (allPesan.isEmpty) {
          return const Center(child: Text('Tidak ada pesan masuk.'));
        }

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