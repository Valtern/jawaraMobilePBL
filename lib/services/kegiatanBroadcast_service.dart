import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/services/log_aktivitas_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KegiatanBroadcastService {
  final String _baseUrl = AuthService().baseUrl;
  final LogAktivitasService _logService = LogAktivitasService();

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

  // ===== BROADCAST =====

  /// List broadcast dengan filter judul dan user_id
  Future<List<dynamic>> getBroadcastList({String? judul, int? userId}) async {
    try {
      final headers = await _authHeaders();
      final query = <String, String>{};
      if ((judul ?? '').isNotEmpty) query['judul'] = judul!;
      if (userId != null) query['user_id'] = userId.toString();
      final uri = Uri.parse(
        '$_baseUrl/broadcasts',
      ).replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      print('GET /broadcasts status: ${resp.statusCode}');
      print('GET /broadcasts body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getBroadcastList: $e');
    }
    return [];
  }

  /// Detail broadcast
  Future<Map<String, dynamic>?> getBroadcast(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(
        Uri.parse('$_baseUrl/broadcasts/$id'),
        headers: headers,
      );
      print('GET /broadcasts/$id status: ${resp.statusCode}');
      print('GET /broadcasts/$id body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('Exception in getBroadcast: $e');
    }
    return null;
  }

  /// Create broadcast
  /// payload minimal: { 'judul': String, 'isi_pesan': String }
  Future<bool> createBroadcast(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/broadcasts'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('POST /broadcasts status: ${resp.statusCode}');
      print('POST /broadcasts body: ${resp.body}');
      final success = resp.statusCode == 201;
      if (success) {
        final judul = payload['judul'] ?? '';
        await _logService.createLog(
          kategori: 'Broadcast',
          deskripsi:
              judul.toString().isNotEmpty
                  ? 'Mengirim broadcast "$judul"'
                  : 'Mengirim broadcast baru',
        );
      }
      return success;
    } catch (e) {
      print('Exception in createBroadcast: $e');
      return false;
    }
  }

  /// Update broadcast
  Future<bool> updateBroadcast(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/broadcasts/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('PUT /broadcasts/$id status: ${resp.statusCode}');
      print('PUT /broadcasts/$id body: ${resp.body}');
      final success = resp.statusCode == 200;
      if (success) {
        final judul = payload['judul'] ?? '';
        await _logService.createLog(
          kategori: 'Broadcast',
          deskripsi:
              judul.toString().isNotEmpty
                  ? 'Memperbarui broadcast "$judul" (ID: $id)'
                  : 'Memperbarui broadcast (ID: $id)',
        );
      }
      return success;
    } catch (e) {
      print('Exception in updateBroadcast: $e');
      return false;
    }
  }

  /// Delete broadcast
  Future<bool> deleteBroadcast(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(
        Uri.parse('$_baseUrl/broadcasts/$id'),
        headers: headers,
      );
      print('DELETE /broadcasts/$id status: ${resp.statusCode}');
      print('DELETE /broadcasts/$id body: ${resp.body}');
      final success = resp.statusCode == 200;
      if (success) {
        await _logService.createLog(
          kategori: 'Broadcast',
          deskripsi: 'Menghapus broadcast (ID: $id)',
        );
      }
      return success;
    } catch (e) {
      print('Exception in deleteBroadcast: $e');
      return false;
    }
  }

  // ===== KEGIATAN =====

  /// List kegiatan dengan berbagai filter
  Future<List<dynamic>> getKegiatanList({
    String? name,
    String? category,
    String? personInCharge,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final headers = await _authHeaders();
      final query = <String, String>{};
      if ((name ?? '').isNotEmpty) query['name'] = name!;
      if ((category ?? '').isNotEmpty) query['category'] = category!;
      if ((personInCharge ?? '').isNotEmpty) {
        query['person_in_charge'] = personInCharge!;
      }
      if ((startDate ?? '').isNotEmpty)
        query['start_date'] = startDate!; // format YYYY-MM-DD
      if ((endDate ?? '').isNotEmpty)
        query['end_date'] = endDate!; // format YYYY-MM-DD

      final uri = Uri.parse(
        '$_baseUrl/kegiatans',
      ).replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      print('GET /kegiatans status: ${resp.statusCode}');
      print('GET /kegiatans body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getKegiatanList: $e');
    }
    return [];
  }

  /// Detail kegiatan
  Future<Map<String, dynamic>?> getKegiatan(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(
        Uri.parse('$_baseUrl/kegiatans/$id'),
        headers: headers,
      );
      print('GET /kegiatans/$id status: ${resp.statusCode}');
      print('GET /kegiatans/$id body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('Exception in getKegiatan: $e');
    }
    return null;
  }

  /// Create kegiatan
  /// payload minimal: { 'name', 'category', 'person_in_charge', 'event_date', 'description?' }
  Future<bool> createKegiatan(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/kegiatans'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('POST /kegiatans status: ${resp.statusCode}');
      print('POST /kegiatans body: ${resp.body}');
      final success = resp.statusCode == 201;
      if (success) {
        final name = payload['name'] ?? '';
        await _logService.createLog(
          kategori: 'Kegiatan',
          deskripsi:
              name.toString().isNotEmpty
                  ? 'Menambahkan kegiatan $name'
                  : 'Menambahkan kegiatan baru',
        );
      }
      return success;
    } catch (e) {
      print('Exception in createKegiatan: $e');
      return false;
    }
  }

  /// Update kegiatan
  Future<bool> updateKegiatan(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/kegiatans/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('PUT /kegiatans/$id status: ${resp.statusCode}');
      print('PUT /kegiatans/$id body: ${resp.body}');
      final success = resp.statusCode == 200;
      if (success) {
        final name = payload['name'] ?? '';
        await _logService.createLog(
          kategori: 'Kegiatan',
          deskripsi:
              name.toString().isNotEmpty
                  ? 'Memperbarui kegiatan $name (ID: $id)'
                  : 'Memperbarui kegiatan (ID: $id)',
        );
      }
      return success;
    } catch (e) {
      print('Exception in updateKegiatan: $e');
      return false;
    }
  }

  /// Delete kegiatan
  Future<bool> deleteKegiatan(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(
        Uri.parse('$_baseUrl/kegiatans/$id'),
        headers: headers,
      );
      print('DELETE /kegiatans/$id status: ${resp.statusCode}');
      print('DELETE /kegiatans/$id body: ${resp.body}');
      final success = resp.statusCode == 200;
      if (success) {
        await _logService.createLog(
          kategori: 'Kegiatan',
          deskripsi: 'Menghapus kegiatan (ID: $id)',
        );
      }
      return success;
    } catch (e) {
      print('Exception in deleteKegiatan: $e');
      return false;
    }
  }
}
