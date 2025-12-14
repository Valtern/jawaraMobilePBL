import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/consistent_tabbar.dart';
import 'package:jawarapbl/modules/kegiatan-broadcast/pages/broadcast.dart';
import 'package:jawarapbl/modules/kegiatan-broadcast/pages/kegiatan.dart';

class KegiatanBroadcastPage extends StatelessWidget {
  const KegiatanBroadcastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConsistentTabBar(
      tabs: ['Kegiatan', 'Broadcast'],
      tabViews: const [
        KegiatanListView(),
        BroadcastListView(),
      ],
    );
  }
}
