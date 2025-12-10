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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final accent = theme.colorScheme.secondary;
    final softBackground = theme.colorScheme.background;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lainnya'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      backgroundColor: softBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: softBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FutureBuilder<User?>(
                    future: _userFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data == null) {
                        return const ProfileCard(
                          name: 'Gagal memuat',
                          email: 'Tidak dapat mengambil data',
                          imageUrl: null,
                        );
                      }

                      final user = snapshot.data!;

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
          ),
        ),
      ),
    );
  }
}