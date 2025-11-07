import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementService {
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

  Future<List<dynamic>> getUsers() async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/users'), headers: headers);
      print('GET /users status: ${resp.statusCode}');
      print('GET /users body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          return (data['data'] as List<dynamic>);
        } else {
          print('API error: ${data['message']}');
        }
      } else {
        print('HTTP error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      print('Exception in getUsers: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(Uri.parse('$_baseUrl/users/$id'), headers: headers);
      print('GET /users/$id status: ${resp.statusCode}');
      print('GET /users/$id body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          print('API error: ${data['message']}');
        }
      } else {
        print('HTTP error ${resp.statusCode}: ${resp.body}');
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
      final respBody = await resp.stream.bytesToString();
      print('POST /users status: ${resp.statusCode}');
      print('POST /users body: $respBody');
      return resp.statusCode == 201;
    } catch (e) {
      print('Exception in createUser: $e');
      return false;
    }
  }

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
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final req = http.MultipartRequest('POST', Uri.parse('$_baseUrl/users/$id'))
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = token != null ? 'Bearer $token' : ''
        ..fields['_method'] = 'PUT'; // Laravel method spoofing for multipart

      void addField(String key, String? val) {
        if (val != null) req.fields[key] = val;
      }

      addField('name', name);
      addField('email', email);
      addField('nik', nik);
      addField('phone', phone);
      addField('role', role);
      addField('status', status);
      if (password != null && password.isNotEmpty) {
        req.fields['password'] = password;
      }
      if (fotoIdentitas != null) {
        req.files.add(await http.MultipartFile.fromPath('foto_identitas', fotoIdentitas.path));
      }

      final resp = await req.send();
      final respBody = await resp.stream.bytesToString();
      print('POST /users/$id status: ${resp.statusCode}');
      print('POST /users/$id body: $respBody');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateUser: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(Uri.parse('$_baseUrl/users/$id'), headers: headers);
      print('DELETE /users/$id status: ${resp.statusCode}');
      print('DELETE /users/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in deleteUser: $e');
      return false;
    }
  }
}
