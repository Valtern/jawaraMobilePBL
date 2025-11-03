import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawarapbl/shared/models/user_model.dart';

class AuthService {
  // Use your ipv4 address or domain name here
  final String _baseUrl = 'http://192.168.100.14:8000/api';
  final String _storageUrl = 'http://192.168.100.14:8000/storage';

  String get storageUrl => _storageUrl;

  Future<String?> login(String email, String password) async {

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('role', data['role']);

        return data['role'];
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> register({
    required String name,
    required String nik,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String jenisKelamin,
    required File? fotoIdentitas,
  }) async {
    try {
      var uri = Uri.parse('$_baseUrl/register');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json';

      // Add text fields
      request.fields['name'] = name;
      request.fields['nik'] = nik;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation;
      request.fields['jenis_kelamin'] = jenisKelamin;

      // Add file
      if (fotoIdentitas != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto_identitas',
            fotoIdentitas.path,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        return true;
      } else {
        final respStr = await response.stream.bytesToString();
        print(respStr);
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<User?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return null; // User is not logged in
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Send the auth token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data); // Parse and return the User
      } else {
        return null; // Failed to fetch
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}