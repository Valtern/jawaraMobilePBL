import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/kegiatan-broadcast/pages/broadcast.dart';
import 'package:jawarapbl/modules/kegiatan-broadcast/pages/kegiatan.dart';

class KegiatanBroadcastPage extends StatelessWidget {
  const KegiatanBroadcastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          TabBar(
            isScrollable: true,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: 'Kegiatan'),
              Tab(text: 'Broadcast'),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                KegiatanListView(),
                BroadcastListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
