import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/shared/models/log_aktivitas_model.dart';

class LogAktivitasService {
  final String _baseUrl = AuthService().baseUrl;

  Future<List<LogAktivitas>> getLogAktivitas({
    String? kategori,
    String? startDate,
    String? endDate,
    int? userId,
  }) async {
    try {
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

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> logList = data['data'];
          return logList.map((json) => LogAktivitas.fromJson(json)).toList();
        }
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
      final response = await http.post(
        Uri.parse('$_baseUrl/log-aktivitas'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'kategori': kategori,
          'deskripsi': deskripsi,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating log aktivitas: $e');
      return false;
    }
  }

  Future<List<String>> getKategoriList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/log-aktivitas/kategori-list'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
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
