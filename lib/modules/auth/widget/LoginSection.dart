import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/auth/pages/register.dart';
import 'package:jawarapbl/services/auth_services.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    String? userRole = await _authService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (userRole != null && context.mounted) {
      switch (userRole) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 'rw':
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 'rt':
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 'bendahara':
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 'sekretaris':
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 'warga':
          Navigator.pushReplacementNamed(context, '/home');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/home');
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login gagal. Periksa email dan password Anda.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Selamat Datang',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masuk untuk mengelola data warga dan keuangan.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: _handleLogin,
                              child: const Text('Login'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/face-login');
                              },
                              icon: const Icon(Icons.face),
                              label: const Text('Login dengan Wajah'),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
              child: const Text(
                'Tidak punya akun? Daftar di sini',
              ),
            ),
          ),
        ],
      ),
    );
  }
}