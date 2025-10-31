import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Use 10.0.2.2 for Android Emulator to connect to your computer's localhost
  final String _baseUrl = 'http://10.0.2.2:8000/api';

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save the token and role
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('role', data['role']);

        // Return the role
        return data['role'];
      } else {
        // Login failed
        return null;
      }
    } catch (e) {
      // Handle network error, etc.
      print(e.toString());
      return null;
    }
  }
}
