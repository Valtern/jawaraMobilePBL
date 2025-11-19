import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PemasukanService {
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

  // ===== KATEGORI IURAN =====

  Future<List<dynamic>> getKategoriIuranList({
    String? name,
    String? jenis,
  }) async {
    try {
      final headers = await _authHeaders();
      final query = <String, String>{};
      if ((name ?? '').isNotEmpty) query['name'] = name!;
      if ((jenis ?? '').isNotEmpty) query['jenis'] = jenis!;

      final uri = Uri.parse(
        '$_baseUrl/kategori-iurans',
      ).replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      print('GET /kategori-iurans status: ${resp.statusCode}');
      print('GET /kategori-iurans body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getKategoriIuranList: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getKategoriIuran(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(
        Uri.parse('$_baseUrl/kategori-iurans/$id'),
        headers: headers,
      );
      print('GET /kategori-iurans/$id status: ${resp.statusCode}');
      print('GET /kategori-iurans/$id body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('Exception in getKategoriIuran: $e');
    }
    return null;
  }

  Future<bool> createKategoriIuran(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/kategori-iurans'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('POST /kategori-iurans status: ${resp.statusCode}');
      print('POST /kategori-iurans body: ${resp.body}');
      return resp.statusCode == 201;
    } catch (e) {
      print('Exception in createKategoriIuran: $e');
      return false;
    }
  }

  Future<bool> updateKategoriIuran(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/kategori-iurans/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('PUT /kategori-iurans/$id status: ${resp.statusCode}');
      print('PUT /kategori-iurans/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateKategoriIuran: $e');
      return false;
    }
  }

  Future<bool> deleteKategoriIuran(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(
        Uri.parse('$_baseUrl/kategori-iurans/$id'),
        headers: headers,
      );
      print('DELETE /kategori-iurans/$id status: ${resp.statusCode}');
      print('DELETE /kategori-iurans/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in deleteKategoriIuran: $e');
      return false;
    }
  }

  // ===== TAGIHAN =====

  Future<List<dynamic>> getTagihanList({
    int? keluargaId,
    int? kategoriIuranId,
    String? paymentStatus,
    String? periode,
    String? dueStart,
    String? dueEnd,
  }) async {
    try {
      final headers = await _authHeaders();
      final query = <String, String>{};
      if (keluargaId != null) query['keluarga_id'] = keluargaId.toString();
      if (kategoriIuranId != null) {
        query['kategori_iuran_id'] = kategoriIuranId.toString();
      }
      if ((paymentStatus ?? '').isNotEmpty) {
        query['payment_status'] = paymentStatus!;
      }
      if ((periode ?? '').isNotEmpty) query['periode'] = periode!;
      if ((dueStart ?? '').isNotEmpty) query['due_start'] = dueStart!;
      if ((dueEnd ?? '').isNotEmpty) query['due_end'] = dueEnd!;

      final uri = Uri.parse(
        '$_baseUrl/tagihans',
      ).replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      print('GET /tagihans status: ${resp.statusCode}');
      print('GET /tagihans body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getTagihanList: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getTagihan(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(
        Uri.parse('$_baseUrl/tagihans/$id'),
        headers: headers,
      );
      print('GET /tagihans/$id status: ${resp.statusCode}');
      print('GET /tagihans/$id body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('Exception in getTagihan: $e');
    }
    return null;
  }

  Future<bool> createTagihan(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/tagihans'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('POST /tagihans status: ${resp.statusCode}');
      print('POST /tagihans body: ${resp.body}');
      return resp.statusCode == 201;
    } catch (e) {
      print('Exception in createTagihan: $e');
      return false;
    }
  }

  Future<bool> updateTagihan(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/tagihans/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('PUT /tagihans/$id status: ${resp.statusCode}');
      print('PUT /tagihans/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateTagihan: $e');
      return false;
    }
  }

  Future<bool> deleteTagihan(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(
        Uri.parse('$_baseUrl/tagihans/$id'),
        headers: headers,
      );
      print('DELETE /tagihans/$id status: ${resp.statusCode}');
      print('DELETE /tagihans/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in deleteTagihan: $e');
      return false;
    }
  }

  // ===== PEMASUKAN LAIN =====

  Future<List<dynamic>> getPemasukanLainList({
    String? name,
    String? jenis,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final headers = await _authHeaders();
      final query = <String, String>{};
      if ((name ?? '').isNotEmpty) query['name'] = name!;
      if ((jenis ?? '').isNotEmpty) query['jenis'] = jenis!;
      if ((startDate ?? '').isNotEmpty) query['start_date'] = startDate!;
      if ((endDate ?? '').isNotEmpty) query['end_date'] = endDate!;

      final uri = Uri.parse(
        '$_baseUrl/pemasukan-lains',
      ).replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      print('GET /pemasukan-lains status: ${resp.statusCode}');
      print('GET /pemasukan-lains body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getPemasukanLainList: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getPemasukanLain(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(
        Uri.parse('$_baseUrl/pemasukan-lains/$id'),
        headers: headers,
      );
      print('GET /pemasukan-lains/$id status: ${resp.statusCode}');
      print('GET /pemasukan-lains/$id body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('Exception in getPemasukanLain: $e');
    }
    return null;
  }

  Future<bool> createPemasukanLain(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/pemasukan-lains'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('POST /pemasukan-lains status: ${resp.statusCode}');
      print('POST /pemasukan-lains body: ${resp.body}');
      return resp.statusCode == 201;
    } catch (e) {
      print('Exception in createPemasukanLain: $e');
      return false;
    }
  }

  Future<bool> updatePemasukanLain(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/pemasukan-lains/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('PUT /pemasukan-lains/$id status: ${resp.statusCode}');
      print('PUT /pemasukan-lains/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updatePemasukanLain: $e');
      return false;
    }
  }

  Future<bool> deletePemasukanLain(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(
        Uri.parse('$_baseUrl/pemasukan-lains/$id'),
        headers: headers,
      );
      print('DELETE /pemasukan-lains/$id status: ${resp.statusCode}');
      print('DELETE /pemasukan-lains/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in deletePemasukanLain: $e');
      return false;
    }
  }
}
