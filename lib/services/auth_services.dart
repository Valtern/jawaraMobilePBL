import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawarapbl/shared/models/user_model.dart';
import 'package:jawarapbl/modules/penerimaan-warga/models/penerimaanwarga_model.dart';

class AuthService {
  // Replace with your actual backend URL
  // use http if you using local ip
  // use https if using hosting server
  String url = 'https://shower-arrival-clarity-winner.trycloudflare.com';
  // String url = 'http://10.222.219.9:8000';

  String get baseUrl => '$url/api';
  String get storageUrl => '$url/storage';

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
      return null;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String nik,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String jenisKelamin,
    int? rumahId,
    String? alamat,
    required File? fotoProfil,
    required File? fotoKtp,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/register');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json';

      request.fields['name'] = name;
      request.fields['nik'] = nik;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation;
      request.fields['jenis_kelamin'] = jenisKelamin;

      if (rumahId != null) {
        request.fields['rumah_id'] = rumahId.toString();
      }
      if (alamat != null && alamat.isNotEmpty) {
        request.fields['alamat'] = alamat;
      }

      if (fotoProfil != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_identitas', fotoProfil.path),
        );
      }

      if (fotoKtp != null) {
        request.files.add(
          await http.MultipartFile.fromPath('foto_ktp', fotoKtp.path),
        );
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(respStr);
        
        final prefs = await SharedPreferences.getInstance();
        if (data['access_token'] != null) {
          await prefs.setString('token', data['access_token']);
        }
        if (data['role'] != null) {
          await prefs.setString('role', data['role']);
        }

        return {
          'success': true,
          'userId': data['user']['id'],
        };
      } else if (response.statusCode == 422) {
        final errors = jsonDecode(respStr) as Map<String, dynamic>;

        if (errors.containsKey('errors')) {
          final validationErrors = errors['errors'] as Map<String, dynamic>;
          final firstErrorKey = validationErrors.keys.first;
          final firstErrorMessage =
              (validationErrors[firstErrorKey] as List).first;
          return {'success': false, 'message': firstErrorMessage};
        }

        final firstErrorKey = errors.keys.first;
        if (errors[firstErrorKey] is List) {
          return {
            'success': false,
            'message': (errors[firstErrorKey] as List).first
          };
        }
        return {'success': false, 'message': 'Data tidak valid.'};
      } else {
        return {
          'success': false,
          'message': 'Pendaftaran gagal. Terjadi kesalahan server.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Pendaftaran gagal. Periksa koneksi internet Anda.'
      };
    }
  }
  Future<String?> enrollFace(List<File> images, int userId) async {
    try {
      print("--- STARTING FACE ENROLLMENT ---");
      print("Sending ${images.length} images for User ID: $userId");

      for (var img in images) {
        int size = await img.length();
        print("Image size: ${(size / 1024).toStringAsFixed(2)} KB");
      }

      final token = await getToken();
      var uri = Uri.parse('$baseUrl/biometric/enroll');
      
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      for (var i = 0; i < images.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('images[]', images[i].path),
        );
      }

      request.fields['user_id'] = userId.toString();

      print("Sending request to $uri...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("Enrollment Success!");
        return null; 
      } else {
        try {
          final errData = jsonDecode(response.body);
          return errData['message'] ?? "Server error: ${response.statusCode}";
        } catch (_) {
          return "Server Error: ${response.statusCode} - ${response.reasonPhrase}";
        }
      }
    } catch (e) {
      print("EXCEPTION DURING ENROLLMENT: $e");
      return "Connection Error: $e";
    }
  }

  Future<String?> loginWithFace(File image, String email) async {
    try {
      print("--- STARTING FACE LOGIN ---");
      print("Email: $email");
      print("Image size: ${(await image.length()) / 1024} KB");

      var uri = Uri.parse('$baseUrl/login-face');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['bypass-tunnel-reminder'] = 'true';

      request.fields['email'] = email;
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Login Response Code: ${response.statusCode}");
      print("Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        await prefs.setString('role', data['role']);
        return data['role'];
      }
      return null;
    } catch (e) {
      print("EXCEPTION DURING FACE LOGIN: $e");
      return null;
    }
  }

Future<String?> updateProfile({
    required String name,
    required String email, 
    required String nik,   
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
      if (token == null) return 'Anda tidak login.';

      var uri = Uri.parse('$baseUrl/profile/update');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = name;
      request.fields['email'] = email; 
      request.fields['nik'] = nik;     
      request.fields['phone'] = phone;
      
      if (tempatLahir != null) request.fields['tempat_lahir'] = tempatLahir;
      if (tanggalLahir != null) {
        request.fields['tanggal_lahir'] = tanggalLahir.toIso8601String().split('T').first;
      }
      if (jenisKelamin != null) request.fields['jenis_kelamin'] = jenisKelamin;
      if (agama != null) request.fields['agama'] = agama;
      if (statusPerkawinan != null) request.fields['status_perkawinan'] = statusPerkawinan;
      if (pekerjaan != null) request.fields['pekerjaan'] = pekerjaan;

      if (fotoProfil != null) {
        request.files.add(await http.MultipartFile.fromPath('foto_identitas', fotoProfil.path));
      }

      var response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return null; 
      } else if (response.statusCode == 422) {
        final errors = jsonDecode(respStr);
        if (errors['errors'] != null) {
            var errorMap = errors['errors'] as Map<String, dynamic>;
            return errorMap.values.first[0]; 
        }
        return 'Data tidak valid.';
      } else {
        return 'Update gagal. Server Error: ${response.statusCode}';
      }
    } catch (e) {
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
        return null;
      } else if (response.statusCode == 422) {
        final errors = data as Map<String, dynamic>;
        final firstErrorKey = errors.keys.first;
        final firstErrorMessage = (errors[firstErrorKey] as List).first;
        return firstErrorMessage;
      } else {
        return data['message'] ?? 'Gagal mengubah password.';
      }
    } catch (e) {
      return 'Update gagal. Periksa koneksi internet Anda.';
    }
  }

  Future<User?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> disableBiometric() async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/biometric/disable'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
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
          if (response.statusCode != 200) {}
        } catch (e) {}
      }

      await prefs.remove('token');
      await prefs.remove('role');

      return true;
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('role');
      } catch (_) {}
      return false;
    }
  }

  Future<List<PenerimaanWarga>> getPenerimaanWarga() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/penerimaan-warga'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => PenerimaanWarga.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateStatusPenerimaan(int id, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/penerimaan-warga/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status_registrasi': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePenerimaan(int id, Map<String, dynamic> body) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception("Not authenticated");
      }

      final response = await http.put(
        Uri.parse("$baseUrl/penerimaan-warga/$id"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePenerimaan(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/penerimaan-warga/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> scanKTP(File imageFile) async {
    try {
      var uri = Uri.parse('$baseUrl/ocr/ktp'); 
      
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
        
      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['data']; 
      }
      return null;
    } catch (e) {
      print("OCR Error: $e");
      return null;
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

      await prefs.remove('token');
      await prefs.remove('role');

      return response.statusCode == 200;
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('role');
      } catch (_) {}
      return false;
    }
  }
}