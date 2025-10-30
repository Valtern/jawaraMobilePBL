import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/lainnya/widgets/account_card.dart';
import 'package:jawarapbl/modules/lainnya/widgets/menus_card.dart';
import 'package:jawarapbl/modules/lainnya/widgets/profile_card.dart';

class LainnyaPage extends StatelessWidget {
  const LainnyaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: const [
        ProfileCard(),
        SizedBox(height: 12),
        MenusCard(),
        SizedBox(height: 12),
        AccountCard(),
        SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Text('Version 1.0.0'),
              SizedBox(height: 4),
              Text('© 2025 Jawara Pintar - Kelompok 3'),
            ],
          ),
        ),
      ],
    );
  }
}
