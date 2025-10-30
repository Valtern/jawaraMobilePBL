import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 32,
              backgroundImage: AssetImage(
                'assets/images/profile-placeholder.png',
              ),
            ),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Jawara Pintar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 1),
                Text(
                  'admin1@gmail.com',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
