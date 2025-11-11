// lib/services/pemasukan_laporan_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jawarapbl/services/auth_services.dart';
import 'package:jawarapbl/shared/models/api_pemasukan_lain_model.dart';
import 'package:jawarapbl/shared/models/api_tagihan_model.dart';
import 'package:jawarapbl/modules/laporan-keuangan/models/semuapemasukan_model.dart';
// ADDED import
import 'package:shared_preferences/shared_preferences.dart';

class PemasukanLaporanService {
  final AuthService _authService = AuthService();
  String get baseUrl => _authService.baseUrl;

  // --- START of ADDED METHODS ---

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }
  
  // --- END of ADDED METHODS ---


  Future<List<PemasukanModel>> getLaporanPemasukan() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pemasukan'),
      // FIXED: Call the local getAuthHeaders method
      headers: await getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      
      // Handle potential null lists from API
      final List tagihanData = body['tagihan'] ?? [];
      final List pemasukanLainData = body['pemasukanLain'] ?? [];

      List<PemasukanModel> combinedList = [];

      // 1. Parse Tagihan (Iuran Warga)
      for (var item in tagihanData) {
        final apiItem = ApiTagihan.fromJson(item);
        
        // Determine the date: use due_date, fallback to created_at
        final String dateString = apiItem.dueDate ?? apiItem.createdAt;
        final DateTime tanggal = DateTime.parse(dateString);

        combinedList.add(PemasukanModel(
          no: apiItem.id,
          nama: 'Iuran Warga - ${apiItem.periode}', // Create a sensible name
          jenisPemasukan: 'Iuran Warga',
          tanggal: DateFormat('dd/MM/yyyy').format(tanggal),
          nominal: double.tryParse(apiItem.nominal) ?? 0.0,
          tanggalSort: tanggal, // Add sortable DateTime
        ));
      }

      // 2. Parse Pemasukan Lain
      for (var item in pemasukanLainData) {
        final apiItem = ApiPemasukanLain.fromJson(item);
        final DateTime tanggal = DateTime.parse(apiItem.tanggal);

        combinedList.add(PemasukanModel(
          no: apiItem.id,
          nama: apiItem.name,
          jenisPemasukan: apiItem.jenis,
          tanggal: DateFormat('dd/MM/yyyy').format(tanggal),
          nominal: double.tryParse(apiItem.nominal) ?? 0.0,
          tanggalSort: tanggal, // Add sortable DateTime
        ));
      }

      // 3. Sort the combined list by date (newest first)
      combinedList.sort((a, b) => b.tanggalSort.compareTo(a.tanggalSort));

      return combinedList;
    } else {
      throw Exception('Gagal memuat data pemasukan laporan');
    }
  }
}