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

  Future<List<dynamic>> getWargaList({
    String? namaLengkap,
    String? nik,
    int? keluargaId,
  }) async {
    try {
      final headers = await _authHeaders();
      final query = <String, String>{};
      if ((namaLengkap ?? '').isNotEmpty) query['nama_lengkap'] = namaLengkap!;
      if ((nik ?? '').isNotEmpty) query['nik'] = nik!;
      if (keluargaId != null) query['keluarga_id'] = keluargaId.toString();
      final uri = Uri.parse('$_baseUrl/wargas').replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      print('GET /wargas status: ${resp.statusCode}');
      print('GET /wargas body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getWargaList: $e');
    }
    return [];
  }

  Future<List<dynamic>> getKeluargaList({
    String? namaKeluarga,
    String? nomorKk,
    int? rumahId,
  }) async {
    try {
      final headers = await _authHeaders();
      final query = <String, String>{};
      if ((namaKeluarga ?? '').isNotEmpty) query['nama_keluarga'] = namaKeluarga!;
      if ((nomorKk ?? '').isNotEmpty) query['nomor_kk'] = nomorKk!;
      if (rumahId != null) query['rumah_id'] = rumahId.toString();
      final uri = Uri.parse('$_baseUrl/keluargas').replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      print('GET /keluargas status: ${resp.statusCode}');
      print('GET /keluargas body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getKeluargaList: $e');
    }
    return [];
  }

  Future<List<dynamic>> getRumahList({
    String? alamat,
    String? statusHunian,
  }) async {
    try {
      final headers = await _authHeaders();
      final query = <String, String>{};
      if ((alamat ?? '').isNotEmpty) query['alamat'] = alamat!;
      if ((statusHunian ?? '').isNotEmpty) query['status_hunian'] = statusHunian!;
      final uri = Uri.parse('$_baseUrl/rumahs').replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      print('GET /rumahs status: ${resp.statusCode}');
      print('GET /rumahs body: ${resp.body}');
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
      final resp = await http.get(Uri.parse('$_baseUrl/wargas/$id'), headers: headers);
      print('GET /wargas/$id status: ${resp.statusCode}');
      print('GET /wargas/$id body: ${resp.body}');
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
      final resp = await http.get(Uri.parse('$_baseUrl/keluargas/$id'), headers: headers);
      print('GET /keluargas/$id status: ${resp.statusCode}');
      print('GET /keluargas/$id body: ${resp.body}');
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
      final resp = await http.get(Uri.parse('$_baseUrl/rumahs/$id'), headers: headers);
      print('GET /rumahs/$id status: ${resp.statusCode}');
      print('GET /rumahs/$id body: ${resp.body}');
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
        Uri.parse('$_baseUrl/wargas'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('POST /wargas status: ${resp.statusCode}');
      print('POST /wargas body: ${resp.body}');
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
        Uri.parse('$_baseUrl/wargas/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('PUT /wargas/$id status: ${resp.statusCode}');
      print('PUT /wargas/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateWarga: $e');
      return false;
    }
  }

  Future<bool> deleteWarga(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(Uri.parse('$_baseUrl/wargas/$id'), headers: headers);
      print('DELETE /wargas/$id status: ${resp.statusCode}');
      print('DELETE /wargas/$id body: ${resp.body}');
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
        Uri.parse('$_baseUrl/keluargas'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('POST /keluargas status: ${resp.statusCode}');
      print('POST /keluargas body: ${resp.body}');
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
        Uri.parse('$_baseUrl/keluargas/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('PUT /keluargas/$id status: ${resp.statusCode}');
      print('PUT /keluargas/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateKeluarga: $e');
      return false;
    }
  }

  Future<bool> deleteKeluarga(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(Uri.parse('$_baseUrl/keluargas/$id'), headers: headers);
      print('DELETE /keluargas/$id status: ${resp.statusCode}');
      print('DELETE /keluargas/$id body: ${resp.body}');
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
        Uri.parse('$_baseUrl/rumahs'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('POST /rumahs status: ${resp.statusCode}');
      print('POST /rumahs body: ${resp.body}');
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
        Uri.parse('$_baseUrl/rumahs/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('PUT /rumahs/$id status: ${resp.statusCode}');
      print('PUT /rumahs/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateRumah: $e');
      return false;
    }
  }

  Future<bool> deleteRumah(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(Uri.parse('$_baseUrl/rumahs/$id'), headers: headers);
      print('DELETE /rumahs/$id status: ${resp.statusCode}');
      print('DELETE /rumahs/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in deleteRumah: $e');
      return false;
    }
  }
}
