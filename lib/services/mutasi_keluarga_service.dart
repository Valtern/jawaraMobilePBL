import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawarapbl/shared/models/mutasi_keluarga_model.dart';
import 'package:jawarapbl/services/auth_services.dart';

class MutasiKeluargaService {
  final String _baseUrl = AuthService().baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<MutasiKeluarga>> getMutasiKeluarga() async {
    try {
      final headers = await _getHeaders(); 
      final response = await http.get(
        Uri.parse('$_baseUrl/mutasi-keluarga'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> mutasiList = data['data'];
          return mutasiList.map((json) => MutasiKeluarga.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching mutasi keluarga: $e');
      return [];
    }
  }

  Future<MutasiKeluarga?> getMutasiKeluargaById(int id) async {
    try {
      final headers = await _getHeaders(); // Use auth headers
      final response = await http.get(
        Uri.parse('$_baseUrl/mutasi-keluarga/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return MutasiKeluarga.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching mutasi keluarga detail: $e');
      return null;
    }
  }

  Future<bool> createMutasiKeluarga(MutasiKeluarga mutasi) async {
    try {
      final headers = await _getHeaders(); 
      final response = await http.post(
        Uri.parse('$_baseUrl/mutasi-keluarga'),
        headers: headers,
        body: jsonEncode(mutasi.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error creating mutasi: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating mutasi keluarga: $e');
      return false;
    }
  }

  Future<bool> updateMutasiKeluarga(MutasiKeluarga mutasi) async {
    try {
      final headers = await _getHeaders(); // FIX: Use auth headers
      final response = await http.put(
        Uri.parse('$_baseUrl/mutasi-keluarga/${mutasi.id}'),
        headers: headers,
        body: jsonEncode(mutasi.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error updating mutasi: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating mutasi keluarga: $e');
      return false;
    }
  }

  Future<bool> deleteMutasiKeluarga(int id) async {
    try {
      final headers = await _getHeaders(); // FIX: Use auth headers
      final response = await http.delete(
        Uri.parse('$_baseUrl/mutasi-keluarga/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error deleting mutasi: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting mutasi keluarga: $e');
      return false;
    }
  }

  Future<List<Keluarga>> getKeluargaList() async {
    try {
      final headers = await _getHeaders(); // Use auth headers
      final response = await http.get(
        Uri.parse('$_baseUrl/keluarga-list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> keluargaList = data['data'];
          return keluargaList.map((json) => Keluarga.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching keluarga list: $e');
      return [];
    }
  }
}