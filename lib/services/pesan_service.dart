import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/modules/pesan-warga/models/user_penerima_model.dart';
import 'package:jawarapbl/modules/pesan-warga/models/pesan_model.dart';
import 'package:jawarapbl/modules/pesan-warga/models/informasiaspirasi_model.dart';

class PesanService {
  final String _baseUrl = AuthService().baseUrl;

  Future<List<Pesan>> getInbox() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/pesan/masuk'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Pesan.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat kotak masuk.');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<List<UserPenerima>> getUsers({String role = 'Semua'}) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/pesan/users?role=$role'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => UserPenerima.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat daftar pengguna.');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<bool> kirimPesan({
    required int penerimaId,
    required String judul,
    required String isi,
  }) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/pesan/kirim'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'penerima_id': penerimaId,
          'judul': judul,
          'isi': isi,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      final body = jsonDecode(response.body);
      String error = body['message'] ?? 'Unknown error';
      if (body['errors'] != null) {
        error = body['errors'].values.first[0];
      }
      throw Exception(error);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> kirimAspirasi({
    required String judul,
    required String isi,
  }) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/aspirasi-warga'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'judul': judul,
          'deskripsi': isi,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      final body = jsonDecode(response.body);
      String error = body['message'] ?? 'Unknown error';
      if (body['errors'] != null) {
        error = body['errors'].values.first[0];
      }
      throw Exception(error);
    } catch (e) {
      rethrow;
    }
  }

  Future<AspirasiWarga> updateAspirasi({
    required int id,
    required String judul,
    required String deskripsi,
  }) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/aspirasi-warga/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'judul': judul,
          'deskripsi': deskripsi,
        }),
      );

      if (response.statusCode == 200) {
        return AspirasiWarga.fromJson(jsonDecode(response.body));
      }
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal update aspirasi');
    } catch (e) {
      rethrow;
    }
  }

  Future<AspirasiWarga> updateAspirasiStatus({
    required int id,
    required String status,
  }) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/aspirasi-warga/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return AspirasiWarga.fromJson(jsonDecode(response.body));
      }
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal update status aspirasi');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteAspirasi(int id) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/aspirasi-warga/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal menghapus aspirasi');
    } catch (e) {
      rethrow;
    }
  }
}