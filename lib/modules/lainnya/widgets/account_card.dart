import 'package:flutter/material.dart';
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/modules/lainnya/pages/edit_profile_page.dart';
import 'package:jawarapbl/shared/widgets/logout_confirmation_dialog.dart';
import 'package:jawarapbl/shared/widgets/page_transitions.dart';
import 'package:jawarapbl/modules/auth/widgets/login_route_wrapper.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({super.key});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  final AuthService authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    final shouldLogout = await showLogoutConfirmationDialog(context: context);

    if (shouldLogout == true) {
      setState(() {
        _isLoading = true;
      });

      final success = await authService.logout();

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        NavigationHelper.navigateToAndClear(
          context,
          const LoginRouteWrapper(),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout gagal. Silakan coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModernMenuItem(
                icon: Icons.settings,
                title: 'Pengaturan',
                onTap: () {
                  NavigationHelper.navigateTo(
                    context,
                    const EditProfilePage(),
                  );
                },
              ),
              _buildModernMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final defaultTextColor = textColor ?? const Color(0xFF2D3436);
    final defaultIconColor = iconColor ?? const Color(0xFF6938EF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: defaultIconColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: defaultTextColor,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
