import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawarapbl/shared/models/user_model.dart';

class AuthService {
  // change to your local ipv4 address and the port to any unused port
  // String get baseUrl => 'http://192.168.0.109:8000/api';
  // String get storageUrl => 'http://192.168.0.109:8000/storage';

  // this one is the domain im running with localtunnel, change it accordingly if you made changes to the api.
  // simply comment below and uncomment the above to run on local network
  String get baseUrl => 'https://jawara-api-group3.loca.lt/api';
  String get storageUrl => 'https://jawara-api-group3.loca.lt/storage';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'bypass-tunnel-reminder': 'true',
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

  Future<String?> register({
    required String name,
    required String nik,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String jenisKelamin,
    required File? fotoProfil,
    required File? fotoKtp,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/register');
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

      // Add profile picture file (optional)
      if (fotoProfil != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_identitas', fotoProfil.path),
        );
      }

      // Add KTP file (optional)
      if (fotoKtp != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_ktp', fotoKtp.path),
        );
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return null;
      } else if (response.statusCode == 422) {
        final errors = jsonDecode(respStr) as Map<String, dynamic>;
        final firstErrorKey = errors.keys.first;
        final firstErrorMessage = (errors[firstErrorKey] as List).first;
        return firstErrorMessage;
      } else {
        print(respStr);
        return 'Pendaftaran gagal. Terjadi kesalahan server.';
      }
    } catch (e) {
      print(e.toString());
      return 'Pendaftaran gagal. Periksa koneksi internet Anda.';
    }
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
    required String? tempatLahir,
    required DateTime? tanggalLahir,
    required String? jenisKelamin,
    required String? agama,
    required String? statusPerkawinan,
    required String? pekerjaan,
    required File? fotoProfil,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return 'Anda tidak login.';
      }

      var uri = Uri.parse('$baseUrl/profile/update');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = name;
      request.fields['phone'] = phone;
      if (tempatLahir != null) request.fields['tempat_lahir'] = tempatLahir;
      if (tanggalLahir != null) {
        request.fields['tanggal_lahir'] = tanggalLahir
            .toIso8601String()
            .split('T')
            .first; // Format as YYYY-MM-DD
      }
      if (jenisKelamin != null) request.fields['jenis_kelamin'] = jenisKelamin;
      if (agama != null) request.fields['agama'] = agama;
      if (statusPerkawinan != null) {
        request.fields['status_perkawinan'] = statusPerkawinan;
      }
      if (pekerjaan != null) request.fields['pekerjaan'] = pekerjaan;

      // Add profile picture file (optional)
      if (fotoProfil != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_identitas', fotoProfil.path),
        );
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString(); // Read response

      if (response.statusCode == 200) {
        return null; // Success
      } else if (response.statusCode == 422) {
        // Validation Error
        final errors = jsonDecode(respStr) as Map<String, dynamic>;
        final firstErrorKey = errors.keys.first;
        final firstErrorMessage = (errors[firstErrorKey] as List).first;
        return firstErrorMessage;
      } else {
        print(respStr);
        return 'Update gagal. Terjadi kesalahan server.';
      }
    } catch (e) {
      print(e.toString());
      return 'Update gagal. Periksa koneksi internet Anda.';
    }
  }

  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        return 'Anda tidak login.';
      }

      final response = await http.post(
        Uri.parse('$baseUrl/profile/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return null; // Success
      } else if (response.statusCode == 422) {
        // Validation Error
        final errors = data as Map<String, dynamic>;
        final firstErrorKey = errors.keys.first;
        final firstErrorMessage = (errors[firstErrorKey] as List).first;
        return firstErrorMessage;
      } else {
        return data['message'] ?? 'Gagal mengubah password.';
      }
    } catch (e) {
      print(e.toString());
      return 'Update gagal. Periksa koneksi internet Anda.';
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
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Send the auth token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/logout'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'bypass-tunnel-reminder': 'true',
            },
          );

          // Log the response for debugging
          if (response.statusCode != 200) {
            print('Logout response: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          print('Server logout failed: $e');
        }
      }

      await prefs.remove('token');
      await prefs.remove('role');

      return true;
    } catch (e) {
      print('Logout error: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('role');
      } catch (_) {}
      return false;
    }
  }
  

  Future<bool> logoutAllDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout-all'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'bypass-tunnel-reminder': 'true',
        },
      );

      // Clear local storage
      await prefs.remove('token');
      await prefs.remove('role');

      return response.statusCode == 200;
    } catch (e) {
      print('Logout all devices error: $e');
      // Still clear local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('role');
      } catch (_) {}
      return false;
    }
  }
}
