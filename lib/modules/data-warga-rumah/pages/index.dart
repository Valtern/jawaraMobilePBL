import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/widgets/consistent_tabbar.dart';
import 'package:jawarapbl/modules/data-warga-rumah/pages/keluarga.dart';
import 'package:jawarapbl/modules/data-warga-rumah/pages/rumah.dart';
import 'package:jawarapbl/modules/data-warga-rumah/pages/warga.dart';

class DataWargaRumahPage extends StatelessWidget {
  const DataWargaRumahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConsistentTabBar(
      tabs: ['Warga', 'Keluarga', 'Rumah'],
      tabViews: const [
        WargaDaftarView(),
        KeluargaListView(),
        RumahListView(),
      ],
    );
  }
}
