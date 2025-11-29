import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/shared/models/log_aktivitas_model.dart';

class LogAktivitasService {
  final String _baseUrl = AuthService().baseUrl;
  final AuthService _authService = AuthService(); 

  Future<List<LogAktivitas>> getLogAktivitas({
    String? kategori,
    String? startDate,
    String? endDate,
    int? userId,
  }) async {
    try {
      final token = await _authService.getToken(); 
      if (token == null) {
        print('Error fetching log aktivitas: Auth token is missing.');
        return [];
      }
      
      var uri = Uri.parse('$_baseUrl/log-aktivitas');
      
      Map<String, String> queryParams = {};
      if (kategori != null && kategori.isNotEmpty) queryParams['kategori'] = kategori;
      if (startDate != null && startDate.isNotEmpty) queryParams['start_date'] = startDate;
      if (endDate != null && endDate.isNotEmpty) queryParams['end_date'] = endDate;
      if (userId != null) queryParams['user_id'] = userId.toString();
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        // Keep: Authorization header for API access
        headers: {
          'Content-Type': 'application/json', 
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> logList = data['data'];
          return logList.map((json) => LogAktivitas.fromJson(json)).toList();
        }
      }
      if (response.statusCode != 200) {
        print('Error fetching log aktivitas: HTTP Status ${response.statusCode}');
      } else {
        print('Error fetching log aktivitas: API responded with success: false');
      }
      
      return [];
    } catch (e) {
      print('Error fetching log aktivitas: $e'); 
      return [];
    }
  }

  Future<bool> createLog({
    int? userId,
    required String kategori,
    required String deskripsi,
  }) async {
    try {
      // Keep: Token retrieval for authentication
      final token = await _authService.getToken(); 
      if (token == null) {
        print('Error creating log aktivitas: Auth token is missing.');
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$_baseUrl/log-aktivitas'),
        // Keep: Authorization header for API access
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
      print('LOG_AKTIVITAS create -> status: ${response.statusCode}');
      try {
        print('LOG_AKTIVITAS create -> body: ${response.body}');
      } catch (_) {}

      // Some APIs may return 200 instead of 201 on success
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating log aktivitas: $e');
      return false;
    }
  }

  Future<List<String>> getKategoriList() async {
    try {
      final token = await _authService.getToken(); 
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