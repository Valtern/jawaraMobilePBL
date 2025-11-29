import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/services/log_aktivitas_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataWargaRumahService {
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

  // ✅ Helper to parse error responses
  String? _parseError(http.Response resp) {
    if (resp.statusCode == 422) {
      try {
        final errors = jsonDecode(resp.body)['errors'] as Map<String, dynamic>;
        final firstErrorKey = errors.keys.first;
        final firstErrorMessage = (errors[firstErrorKey] as List).first;
        return firstErrorMessage;
      } catch (e) {
        return 'Terjadi kesalahan validasi.';
      }
    }
    return jsonDecode(resp.body)['message'] ?? 'Terjadi kesalahan server.';
  }

  // --- ADDED: Public Fetch for Registration ---
  Future<List<dynamic>> getRumahOptions() async {
    try {
      // Use simple headers without Token if not available
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      final uri = Uri.parse('$_baseUrl/rumahs-options');
      final resp = await http.get(uri, headers: headers);
      
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is Map && data.containsKey('data')) {
           return (data['data'] as List<dynamic>);
        }
      }
    } catch (e) {
      print('Exception in getRumahOptions: $e');
    }
    return [];
  }
  // --------------------------------------------

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
      final uri = Uri.parse('$_baseUrl/wargas')
          .replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is Map && data.containsKey('data')) {
           return (data['data'] as List<dynamic>);
        }
        if (data is List) {
          return data;
        }
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
      if ((namaKeluarga ?? '').isNotEmpty) {
        query['nama_keluarga'] = namaKeluarga!;
      }
      if ((nomorKk ?? '').isNotEmpty) query['nomor_kk'] = nomorKk!;
      if (rumahId != null) query['rumah_id'] = rumahId.toString();
      final uri = Uri.parse('$_baseUrl/keluargas')
          .replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
         if (data is Map && data.containsKey('data')) {
           return (data['data'] as List<dynamic>);
        }
        if (data is List) {
          return data;
        }
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
      if ((statusHunian ?? '').isNotEmpty) {
        query['status_hunian'] = statusHunian!;
      }
      final uri = Uri.parse('$_baseUrl/rumahs')
          .replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
         if (data is Map && data.containsKey('data')) {
           return (data['data'] as List<dynamic>);
        }
        if (data is List) {
          return data;
        }
      }
    } catch (e) {
      print('Exception in getRumahList: $e');
    }
    return [];
  }

  Future<String?> createWarga(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/wargas'),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 201) {
        final nama = payload['nama_lengkap'] ?? '';
        await _logService.createLog(
          kategori: 'Data Warga',
          deskripsi:
              nama.toString().isNotEmpty
                  ? 'Menambahkan data warga $nama'
                  : 'Menambahkan data warga baru',
        );
        return null;
      }
      return _parseError(resp); // Failure
    } catch (e) {
      print('Exception in createWarga: $e');
      return 'Terjadi error: $e';
    }
  }

  Future<String?> updateWarga(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/wargas/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 200) {
        final nama = payload['nama_lengkap'] ?? '';
        await _logService.createLog(
          kategori: 'Data Warga',
          deskripsi:
              nama.toString().isNotEmpty
                  ? 'Memperbarui data warga $nama (ID: $id)'
                  : 'Memperbarui data warga (ID: $id)',
        );
        return null;
      }
      return _parseError(resp);
    } catch (e) {
      print('Exception in updateWarga: $e');
      return 'Terjadi error: $e';
    }
  }

  Future<String?> deleteWarga(int id) async {
    try {
      final headers = await _authHeaders();
      final resp =
          await http.delete(Uri.parse('$_baseUrl/wargas/$id'), headers: headers);
      if (resp.statusCode == 200) {
        await _logService.createLog(
          kategori: 'Data Warga',
          deskripsi: 'Menghapus data warga (ID: $id)',
        );
        return null;
      }
      return _parseError(resp);
    } catch (e) {
      print('Exception in deleteWarga: $e');
      return 'Terjadi error: $e';
    }
  }

  Future<String?> createKeluarga(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/keluargas'),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 201) {
        final nama = payload['nama_keluarga'] ?? '';
        await _logService.createLog(
          kategori: 'Data Warga - Keluarga',
          deskripsi:
              nama.toString().isNotEmpty
                  ? 'Menambahkan keluarga $nama'
                  : 'Menambahkan data keluarga baru',
        );
        return null;
      }
      return _parseError(resp);
    } catch (e) {
      print('Exception in createKeluarga: $e');
      return 'Terjadi error: $e';
    }
  }

  Future<String?> updateKeluarga(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/keluargas/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 200) {
        final nama = payload['nama_keluarga'] ?? '';
        await _logService.createLog(
          kategori: 'Data Warga - Keluarga',
          deskripsi:
              nama.toString().isNotEmpty
                  ? 'Memperbarui keluarga $nama (ID: $id)'
                  : 'Memperbarui data keluarga (ID: $id)',
        );
        return null;
      }
      return _parseError(resp);
    } catch (e) {
      print('Exception in updateKeluarga: $e');
      return 'Terjadi error: $e';
    }
  }

  Future<String?> deleteKeluarga(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http
          .delete(Uri.parse('$_baseUrl/keluargas/$id'), headers: headers);
      if (resp.statusCode == 200) {
        await _logService.createLog(
          kategori: 'Data Warga - Keluarga',
          deskripsi: 'Menghapus data keluarga (ID: $id)',
        );
        return null;
      }
      return _parseError(resp);
    } catch (e) {
      print('Exception in deleteKeluarga: $e');
      return 'Terjadi error: $e';
    }
  }

  Future<String?> createRumah(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/rumahs'),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 201) {
        final alamat = payload['alamat'] ?? '';
        await _logService.createLog(
          kategori: 'Data Warga - Rumah',
          deskripsi:
              alamat.toString().isNotEmpty
                  ? 'Menambahkan data rumah di $alamat'
                  : 'Menambahkan data rumah baru',
        );
        return null;
      }
      return _parseError(resp);
    } catch (e) {
      print('Exception in createRumah: $e');
      return 'Terjadi error: $e';
    }
  }

  Future<String?> updateRumah(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/rumahs/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 200) {
        final alamat = payload['alamat'] ?? '';
        await _logService.createLog(
          kategori: 'Data Warga - Rumah',
          deskripsi:
              alamat.toString().isNotEmpty
                  ? 'Memperbarui data rumah di $alamat (ID: $id)'
                  : 'Memperbarui data rumah (ID: $id)',
        );
        return null;
      }
      return _parseError(resp);
    } catch (e) {
      print('Exception in updateRumah: $e');
      return 'Terjadi error: $e';
    }
  }

  Future<String?> deleteRumah(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(Uri.parse('$_baseUrl/rumahs/$id'), headers: headers);
      if (resp.statusCode == 200) {
        await _logService.createLog(
          kategori: 'Data Warga - Rumah',
          deskripsi: 'Menghapus data rumah (ID: $id)',
        );
        return null;
      }
      return _parseError(resp);
    } catch (e) {
      print('Exception in deleteRumah: $e');
      return 'Terjadi error: $e';
    }
  }
}