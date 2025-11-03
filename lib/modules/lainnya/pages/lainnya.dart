import 'package:flutter/material.dart';
import 'package:jawarapbl/shared/models/user_model.dart';
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/modules/lainnya/widgets/profile_card.dart';
import 'package:jawarapbl/modules/lainnya/widgets/menus_card.dart';
import 'package:jawarapbl/modules/lainnya/widgets/account_card.dart';

class LainnyaPage extends StatefulWidget {
  const LainnyaPage({super.key});

  @override
  State<LainnyaPage> createState() => _LainnyaPageState();
}

class _LainnyaPageState extends State<LainnyaPage> {
  final AuthService _authService = AuthService();
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lainnya'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<User?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const ProfileCard(
                    name: 'Gagal memuat',
                    email: 'Tidak dapat mengambil data',
                    imageUrl: null,
                  );
                }

                final user = snapshot.data!;

                // Construct the full image URL
                final imageUrl = (user.fotoIdentitas != null)
                    ? '${_authService.storageUrl}/${user.fotoIdentitas}'
                    : null;

                return ProfileCard(
                  name: user.name,
                  email: user.email,
                  imageUrl: imageUrl,
                );
              },
            ),
            const SizedBox(height: 16),
            const MenusCard(),
            const SizedBox(height: 16),
            const AccountCard(),
          ],
        ),
      ),
    );
  }
}