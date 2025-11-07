import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/shared/models/log_aktivitas_model.dart';

class LogAktivitasService {
  final String _baseUrl = AuthService().baseUrl;
  // New: Instance of AuthService to retrieve the token
  final AuthService _authService = AuthService();

  Future<List<LogAktivitas>> getLogAktivitas({
    String? kategori,
    String? startDate,
    String? endDate,
    int? userId,
  }) async {
    try {
      // New: 1. Get Authentication Token
      final token = await _authService.getToken(); 
      if (token == null) {
        print('**LOG AKTIVITAS DEBUG**');
        print('Error: Auth token is missing. User is likely logged out.');
        return [];
      }

      var uri = Uri.parse('$_baseUrl/log-aktivitas');
      
      // Add query parameters for filtering
      Map<String, String> queryParams = {};
      if (kategori != null && kategori.isNotEmpty) queryParams['kategori'] = kategori;
      if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;
      if (userId != null) queryParams['user_id'] = userId.toString();
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // 🪵 LOG: Request URL and Token Status
      print('**LOG AKTIVITAS DEBUG**');
      print('Status: Attempting to fetch logs.'); 
      print('Request URL: $uri'); 
      print('Token: Bearer $token (Sent)'); 

      // New: 2. Include Authorization Header
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json', 
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // FIX: Add the token here
        },
      );

      // 🪵 LOG: Response Status Code
      print('Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> logList = data['data'];
          // 🪵 LOG: Success and data count
          print('Data fetched successfully. Total logs: ${logList.length}');
          return logList.map((json) => LogAktivitas.fromJson(json)).toList();
        } else {
          // 🪵 LOG: Logical error from API response
          print('API responded with success: false. Full Body: ${response.body}');
          return [];
        }
      } else {
        // 🪵 LOG: HTTP error (like 401)
        print('HTTP Request Failed! Status: ${response.statusCode}, Body: ${response.body}');
        return [];
      }
    } catch (e) {
      // 🪵 LOG: Network or decoding exception
      print('Error fetching log aktivitas (Exception): $e');
      return [];
    }
  }

  Future<bool> createLog({
    int? userId,
    required String kategori,
    required String deskripsi,
  }) async {
    try {
      // New: Get Token for POST request as well
      final token = await _authService.getToken(); 
      if (token == null) {
        print('Error: Auth token is missing for createLog.');
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/log-aktivitas'),
        // New: Include Authorization Header
        headers: {
          'Content-Type': 'application/json', 
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'kategori': kategori,
          'deskripsi': deskripsi,
        }),
      );

      // 🪵 LOG: Create Log status
      if (response.statusCode != 201) {
        print('Create Log Failed. Status: ${response.statusCode}, Body: ${response.body}');
      }

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating log aktivitas: $e');
      return false;
    }
  }

  Future<List<String>> getKategoriList() async {
    try {
      // New: Get Token for GET request as well
      final token = await _authService.getToken(); 
      // Note: getKategoriList might be public, but adding token is safe if it's protected
      final headers = {
        'Content-Type': 'application/json', 
        'Accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/log-aktivitas/kategori-list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error fetching kategori list: $e');
      return [];
    }
  }
}