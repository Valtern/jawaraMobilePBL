import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawarapbl/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelTransferService {
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

  // LIST with filters: bank_name, account_number, account_name
  Future<List<dynamic>> getChannelTransferList({
    String? bankName,
    String? accountNumber,
    String? accountName,
  }) async {
    try {
      final headers = await _authHeaders();
      final query = <String, String>{};
      if ((bankName ?? '').isNotEmpty) query['bank_name'] = bankName!;
      if ((accountNumber ?? '').isNotEmpty) query['account_number'] = accountNumber!;
      if ((accountName ?? '').isNotEmpty) query['account_name'] = accountName!;
      final uri = Uri.parse('$_baseUrl/channel-transfers')
          .replace(queryParameters: query.isEmpty ? null : query);
      final resp = await http.get(uri, headers: headers);
      print('GET /channel-transfers status: ${resp.statusCode}');
      print('GET /channel-transfers body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return (data['data'] as List<dynamic>);
      }
    } catch (e) {
      print('Exception in getChannelTransferList: $e');
    }
    return [];
  }

  // SHOW detail
  Future<Map<String, dynamic>?> getChannelTransfer(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.get(
        Uri.parse('$_baseUrl/channel-transfers/$id'),
        headers: headers,
      );
      print('GET /channel-transfers/$id status: ${resp.statusCode}');
      print('GET /channel-transfers/$id body: ${resp.body}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true) return data['data'];
      }
    } catch (e) {
      print('Exception in getChannelTransfer: $e');
    }
    return null;
  }

  // CREATE
  Future<bool> createChannelTransfer(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.post(
        Uri.parse('$_baseUrl/channel-transfers'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('POST /channel-transfers status: ${resp.statusCode}');
      print('POST /channel-transfers body: ${resp.body}');
      return resp.statusCode == 201;
    } catch (e) {
      print('Exception in createChannelTransfer: $e');
      return false;
    }
  }

  // UPDATE
  Future<bool> updateChannelTransfer(int id, Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.put(
        Uri.parse('$_baseUrl/channel-transfers/$id'),
        headers: headers,
        body: jsonEncode(payload),
      );
      print('PUT /channel-transfers/$id status: ${resp.statusCode}');
      print('PUT /channel-transfers/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in updateChannelTransfer: $e');
      return false;
    }
  }

  // DELETE
  Future<bool> deleteChannelTransfer(int id) async {
    try {
      final headers = await _authHeaders();
      final resp = await http.delete(
        Uri.parse('$_baseUrl/channel-transfers/$id'),
        headers: headers,
      );
      print('DELETE /channel-transfers/$id status: ${resp.statusCode}');
      print('DELETE /channel-transfers/$id body: ${resp.body}');
      return resp.statusCode == 200;
    } catch (e) {
      print('Exception in deleteChannelTransfer: $e');
      return false;
    }
  }
}
