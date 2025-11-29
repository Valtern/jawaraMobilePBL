import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // Add this import
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cetaklaporan_model.dart';

class LaporanPdfGenerator {
  static Future<void> generateAndPrintPdf(
    BuildContext context,
    List<LaporanItem> items,
    DateTime dariTanggal,
    DateTime sampaiTanggal,
    String kategori,
  ) async {
    String currentStep = 'Starting';
    
    try {
      currentStep = 'Creating PDF document';
      final pdf = pw.Document();
      
      currentStep = 'Setting up currency format';
      final formatCurrency = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      // --- CHANGE START: Load Local Fonts ---
      // This prevents reliance on default font loaders and matches your app theme
      currentStep = 'Loading assets';
      final fontData = await rootBundle.load("assets/fonts/Poppins-Regular.ttf");
      final fontBoldData = await rootBundle.load("assets/fonts/Poppins-Bold.ttf");
      
      final font = pw.Font.ttf(fontData);
      final boldFont = pw.Font.ttf(fontBoldData);
      // --- CHANGE END ---

      currentStep = 'Calculating total';
      double total = 0;
      for (var item in items) {
        total += (item.tipe == LaporanItemTipe.pemasukan)
            ? item.nominal
            : -item.nominal;
      }

      currentStep = 'Building PDF page';
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          // Use the loaded fonts here
          theme: pw.ThemeData.withFont(
            base: font,
            bold: boldFont,
          ),
          build: (pw.Context context) {
            return [
              _buildHeader(
                  context, dariTanggal, sampaiTanggal, kategori, font, boldFont),
              _buildTable(context, items, font, boldFont, formatCurrency),
              pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
              _buildTotals(context, total, font, boldFont, formatCurrency),
            ];
          },
        ),
      );

      currentStep = 'Generating PDF bytes';
      
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => WillPopScope(
            onWillPop: () async => false,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Membuat PDF...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final Uint8List bytes = await pdf.save();

      currentStep = 'Closing dialog';
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Small delay to ensure dialog animation finishes
      await Future.delayed(const Duration(milliseconds: 200));

      currentStep = 'Opening print preview';
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Laporan_Keuangan_${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
      );
      
      currentStep = 'Complete';
      
    } catch (e) {
      if (context.mounted) {
        try {
          Navigator.of(context).pop(); // Close loading dialog
        } catch (_) {}
        
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed at step: $currentStep'),
                  const SizedBox(height: 8),
                  Text('Error: $e'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  static pw.Widget _buildHeader(
    pw.Context context,
    DateTime dariTanggal,
    DateTime sampaiTanggal,
    String kategori,
    pw.Font font,
    pw.Font boldFont,
  ) {
    final formatDate = DateFormat('dd MMMM yyyy', 'id_ID');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Laporan Keuangan',
          style: pw.TextStyle(font: boldFont, fontSize: 20),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Periode: ${formatDate.format(dariTanggal)} - ${formatDate.format(sampaiTanggal)}',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.Text(
          'Kategori: $kategori',
          style: pw.TextStyle(font: font, fontSize: 12),
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildTable(
    pw.Context context,
    List<LaporanItem> items,
    pw.Font font,
    pw.Font boldFont,
    NumberFormat formatCurrency,
  ) {
    
    final headers = [
      'Tanggal',
      'Nama Item',
      'Kategori',
      'Pemasukan',
      'Pengeluaran'
    ];

    final data = items.map((item) {
      return [
        item.tanggalFormatted,
        item.nama,
        item.kategori,
        item.tipe == LaporanItemTipe.pemasukan
            ? formatCurrency.format(item.nominal)
            : '-',
        item.tipe == LaporanItemTipe.pengeluaran
            ? formatCurrency.format(item.nominal)
            : '-',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: boldFont, fontSize: 10),
      cellStyle: pw.TextStyle(font: font, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTotals(
    pw.Context context,
    double total,
    pw.Font font,
    pw.Font boldFont,
    NumberFormat formatCurrency,
  ) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            'Total: ${formatCurrency.format(total)}',
            style: pw.TextStyle(font: boldFont, fontSize: 14),
          ),
        ],
      ),
    );
  }
}