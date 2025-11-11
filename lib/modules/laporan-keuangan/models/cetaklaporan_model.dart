// lib/modules/laporan-keuangan/models/cetaklaporan_model.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum LaporanItemTipe { pemasukan, pengeluaran }

class LaporanItem {
  final String id;
  final String nama;
  final String kategori;
  final double nominal;
  final DateTime tanggal;
  final LaporanItemTipe tipe;

  LaporanItem({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.nominal,
    required this.tanggal,
    required this.tipe,
  });

  String get tanggalFormatted {
    return DateFormat('dd/MM/yyyy').format(tanggal);
  }

  String get nominalFormatted {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(nominal);
  }

  Color get color {
    return tipe == LaporanItemTipe.pemasukan
        ? Colors.green.shade700
        : Colors.red.shade700;
  }

  // Helper to allow simple equality checks in Sets
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LaporanItem && runtimeType == other.runtimeType && id == other.id && tipe == other.tipe;

  @override
  int get hashCode => id.hashCode ^ tipe.hashCode;
}