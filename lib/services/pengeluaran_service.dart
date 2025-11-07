import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawarapbl/shared/models/pengeluaran_model.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:jawarapbl/services/auth_services.dart';

class PengeluaranService {
  final AuthService _authService = AuthService();
  String get baseUrl => _authService.baseUrl;
  String get storageUrl => _authService.storageUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  // GET /api/pengeluaran
  // MODIFIED: Now accepts a filter map
  Future<List<Pengeluaran>> getPengeluaran(Map<String, String> filters) async {
    try {
      // Build the URI with query parameters
      final uri = Uri.parse('$baseUrl/pengeluaran').replace(
        queryParameters: filters.isEmpty ? null : filters,
      );

      final response = await http.get(
        uri,
        headers: await getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Pengeluaran.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expenses. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Returns a Map with success status and message
  Future<Map<String, dynamic>> createPengeluaran(Map<String, String> data, File? buktiFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/pengeluaran'),
      );
      request.headers.addAll(await getAuthHeaders());
      request.fields.addAll(data);

      if (buktiFile != null) {
        var stream = http.ByteStream(DelegatingStream.typed(buktiFile.openRead()));
        var length = await buktiFile.length();
        var multipartFile = http.MultipartFile('bukti', stream, length,
            filename: basename(buktiFile.path));
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        var message = 'Gagal membuat data. Status: ${response.statusCode}';
        try {
          var jsonData = json.decode(responseBody);
          if (jsonData['message'] != null) {
            message = jsonData['message'];
          }
        } catch (e) {
          message = 'Server error. Status: ${response.statusCode}';
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Returns a Map with success status and message
  Future<Map<String, dynamic>> updatePengeluaran(String id, Map<String, String> data, File? buktiFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/pengeluaran/$id'),
      );
      request.headers.addAll(await getAuthHeaders());
      request.fields.addAll(data);
      request.fields['_method'] = 'PUT';

      if (buktiFile != null) {
        var stream = http.ByteStream(DelegatingStream.typed(buktiFile.openRead()));
        var length = await buktiFile.length();
        var multipartFile = http.MultipartFile('bukti', stream, length,
            filename: basename(buktiFile.path));
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        var message = 'Gagal memperbarui data. Status: ${response.statusCode}';
        try {
          var jsonData = json.decode(responseBody);
          if (jsonData['message'] != null) {
            message = jsonData['message'];
          }
        } catch (e) {
          message = 'Server error. Status: ${response.statusCode}';
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // DELETE /api/pengeluaran/{id}
  Future<bool> deletePengeluaran(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/pengeluaran/$id'),
        headers: await getAuthHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}