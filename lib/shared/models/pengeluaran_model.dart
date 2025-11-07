// lib/shared/models/pengeluaran_model.dart

import 'package:jawarapbl/shared/models/user_model.dart';

class Pengeluaran {
  final int id;
  final String nama;
  final DateTime tanggal;
  final String kategori;
  final double nominal;
  final String? buktiUrl;
  final String? deskripsi;
  final int? userId;
  final User? user;

  Pengeluaran({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.kategori,
    required this.nominal,
    this.buktiUrl,
    this.deskripsi,
    this.userId,
    this.user,
  });

  factory Pengeluaran.fromJson(Map<String, dynamic> json) {
    return Pengeluaran(
      id: json['id'],
      nama: json['nama'],
      tanggal: DateTime.parse(json['tanggal']),
      kategori: json['kategori'],
      nominal: double.parse(json['nominal'].toString()),
      buktiUrl: json['bukti_url'],
      deskripsi: json['deskripsi'],
      userId: json['user_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, String> toMap() {
    return {
      'nama': nama,
      'tanggal': tanggal.toIso8601String().split('T').first, // Format as YYYY-MM-DD
      'kategori': kategori,
      'nominal': nominal.toString(),
      'deskripsi': deskripsi ?? '',
      'user_id': userId.toString(),
    };
  }
}