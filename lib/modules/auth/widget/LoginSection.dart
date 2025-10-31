import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/auth/pages/register.dart';
import 'package:jawarapbl/services/auth_services.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Controllers to get text from TextFields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // This function handles the login button tap
  void _handleLogin() async {
    // Show a loading indicator
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    // Call your API
    String? userRole = await _authService.login(email, password);

    // Hide loading indicator
    setState(() {
      _isLoading = false;
    });

    // Check if login was successful
    if (userRole != null && context.mounted) {
      // Login successful, navigate based on the role
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
      // Login failed, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Failed. Please check email and password.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Replace this with your actual UI.
    // This is just an example.
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

          // Show a progress indicator or the login button
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _handleLogin, // Call the login function
                  child: const Text('Login'),
                ),

          const SizedBox(height: 16), // Spacer
          // --- ADDED THE REGISTER BUTTON BACK ---
          TextButton(
            onPressed: () {
              // Navigate to your RegisterPage
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
