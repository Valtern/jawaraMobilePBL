import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/services/log_aktivitas_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementService {
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

  Future<List<dynamic>> getUsers() async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/users'), headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          return (data['data'] as List<dynamic>);
        }
      }
    } catch (e) {
      print('Exception in getUsers: $e');
    }
    return [];
  }

  // UPDATED: Now returns detailed user data including 'warga'
  Future<Map<String, dynamic>?> getUser(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/users/$id'), headers: headers);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Exception in getUser: $e');
    }
    return null;
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String nik,
    String? phone,
    required String password,
    required String role,
    String status = 'active',
    File? fotoIdentitas,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final req = http.MultipartRequest('POST', Uri.parse('$_baseUrl/users'))
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = token != null ? 'Bearer $token' : ''
        ..fields['name'] = name
        ..fields['email'] = email
        ..fields['nik'] = nik
        ..fields['role'] = role
        ..fields['status'] = status
        ..fields['password'] = password;
      if (phone != null) req.fields['phone'] = phone;
      if (fotoIdentitas != null) {
        req.files.add(await http.MultipartFile.fromPath('foto_identitas', fotoIdentitas.path));
      }
      final resp = await req.send();
      final success = resp.statusCode == 201;
      if (success) {
        await _logService.createLog(
          kategori: 'Manajemen Pengguna',
          deskripsi: 'Menambahkan pengguna baru dengan email $email dan role $role',
        );
      }
      return success;
    } catch (e) {
      print('Exception in createUser: $e');
      return false;
    }
  }

  // UPDATED: Added Warga fields to parameters
  Future<bool> updateUser({
    required int id,
    String? name,
    String? email,
    String? nik,
    String? phone,
    String? password,
    String? role,
    String? status,
    File? fotoIdentitas,
    // Warga Fields
    String? tempatLahir,
    String? tanggalLahir, // YYYY-MM-DD
    String? jenisKelamin,
    String? agama,
    String? statusPerkawinan,
    String? pekerjaan,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final req = http.MultipartRequest('POST', Uri.parse('$_baseUrl/users/$id'))
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = token != null ? 'Bearer $token' : ''
        ..fields['_method'] = 'PUT'; 

      void addField(String key, String? val) {
        if (val != null) req.fields[key] = val;
      }

      // User Fields
      addField('name', name);
      addField('email', email);
      addField('nik', nik);
      addField('phone', phone);
      addField('role', role);
      addField('status', status);
      if (password != null && password.isNotEmpty) {
        req.fields['password'] = password;
      }
      
      // Warga Fields
      addField('tempat_lahir', tempatLahir);
      addField('tanggal_lahir', tanggalLahir);
      addField('jenis_kelamin', jenisKelamin);
      addField('agama', agama);
      addField('status_perkawinan', statusPerkawinan);
      addField('pekerjaan', pekerjaan);

      if (fotoIdentitas != null) {
        req.files.add(await http.MultipartFile.fromPath('foto_identitas', fotoIdentitas.path));
      }

      final resp = await req.send();
      final respBody = await resp.stream.bytesToString();
      print('Update User Response: $respBody');
      final success = resp.statusCode == 200;
      if (success) {
        await _logService.createLog(
          kategori: 'Manajemen Pengguna',
          deskripsi: 'Memperbarui pengguna (ID: $id${email != null ? ', email $email' : ''})',
        );
      }
      return success;
    } catch (e) {
      print('Exception in updateUser: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(Uri.parse('$_baseUrl/users/$id'), headers: headers);
      final success = resp.statusCode == 200;
      if (success) {
        await _logService.createLog(
          kategori: 'Manajemen Pengguna',
          deskripsi: 'Menghapus pengguna (ID: $id)',
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}