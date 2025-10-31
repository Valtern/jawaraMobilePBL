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
          content: Text('Login Failed. Please check email and password.'),
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 32),

          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Login'),
                ),

          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            child: const Text("Don't have an account? Register"),
          ),
        ],
      ),
    );
  }
}
