import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cetaklaporan_model.dart';

class LaporanPdfGenerator {
  static Future<void> generateAndPrintPdf(
    List<LaporanItem> items,
    DateTime dariTanggal,
    DateTime sampaiTanggal,
    String kategori,
  ) async {
    final pdf = pw.Document();
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Load fonts
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          double total = 0;
          items.forEach((item) {
            total += (item.tipe == LaporanItemTipe.pemasukan)
                ? item.nominal
                : -item.nominal;
          });

          return [
            _buildHeader(context, dariTanggal, sampaiTanggal, kategori, font, boldFont),
            _buildTable(context, items, font, boldFont, formatCurrency),
            pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
            _buildTotals(context, total, font, boldFont, formatCurrency),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
    final headers = ['Tanggal', 'Nama Item', 'Kategori', 'Pemasukan', 'Pengeluaran'];

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