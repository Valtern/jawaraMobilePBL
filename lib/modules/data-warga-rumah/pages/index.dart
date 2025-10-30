import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/data-warga-rumah/pages/keluarga.dart';
import 'package:jawarapbl/modules/data-warga-rumah/pages/rumah.dart';
import 'package:jawarapbl/modules/data-warga-rumah/pages/warga.dart';

class DataWargaRumahPage extends StatelessWidget {
  const DataWargaRumahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            isScrollable: true,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(text: 'Warga'),
              Tab(text: 'Keluarga'),
              Tab(text: 'Rumah'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: const [
                WargaDaftarView(),
                KeluargaListView(),
                RumahListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
