import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawarapbl/services/auth_services.dart'; 

class DashboardService {
  // Replace with your actual base URL logic
  final String baseUrl = AuthService().baseUrl; 

  Future<Map<String, dynamic>> getDashboardStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/stats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return decoded['data'] ?? {};
    } else {
      throw Exception('Failed to load dashboard stats: ${response.statusCode}');
    }
  }
}