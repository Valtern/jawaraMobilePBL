import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataWargaRumahService {
  final String _baseUrl = AuthService().baseUrl;

  Future<Map<String, String>> _authHeaders({bool jsonType = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = <String, String>{
      'Accept': 'application/json',
      if (jsonType) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return headers;
  }

  Future<List<dynamic>> getWargaList() async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/warga'), headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getWargaList: $e');
    }
    return [];
  }

  Future<List<dynamic>> getKeluargaList() async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/keluarga'), headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getKeluargaList: $e');
    }
    return [];
  }

  Future<List<dynamic>> getRumahList() async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/rumah'), headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getRumahList: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getWarga(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/warga/$id'), headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('Exception in getWarga: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getKeluarga(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/keluarga/$id'), headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('Exception in getKeluarga: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getRumah(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/rumah/$id'), headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('Exception in getRumah: $e');
    }
    return null;
  }

  Future<bool> createWarga(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/warga'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return resp.statusCode == 201;
    } catch (e) {
      print('Exception in createWarga: $e');
      return false;
    }
  }

  Future<bool> updateWarga(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/warga/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateWarga: $e');
      return false;
    }
  }

  Future<bool> deleteWarga(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(Uri.parse('$_baseUrl/warga/$id'), headers: headers);
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in deleteWarga: $e');
      return false;
    }
  }

  Future<bool> createKeluarga(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/keluarga'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return resp.statusCode == 201;
    } catch (e) {
      print('Exception in createKeluarga: $e');
      return false;
    }
  }

  Future<bool> updateKeluarga(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/keluarga/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateKeluarga: $e');
      return false;
    }
  }

  Future<bool> deleteKeluarga(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(Uri.parse('$_baseUrl/keluarga/$id'), headers: headers);
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in deleteKeluarga: $e');
      return false;
    }
  }

  Future<bool> createRumah(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/rumah'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return resp.statusCode == 201;
    } catch (e) {
      print('Exception in createRumah: $e');
      return false;
    }
  }

  Future<bool> updateRumah(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/rumah/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateRumah: $e');
      return false;
    }
  }

  Future<bool> deleteRumah(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(Uri.parse('$_baseUrl/rumah/$id'), headers: headers);
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in deleteRumah: $e');
      return false;
    }
  }
}
