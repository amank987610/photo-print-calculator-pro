import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/utils/app_formatters.dart';
import '../data/models/calculation_record.dart';

/// Builds a clean, professional A5-ish invoice PDF for a single
/// [CalculationRecord] and exposes save / share / print actions on top
/// of the `printing` plugin (which itself wraps platform print dialogs
/// and file sharing, no extra native code required).
class PdfService {
  static const PdfColor _navy = PdfColor.fromInt(0xFF0D47A1);
  static const PdfColor _orange = PdfColor.fromInt(0xFFFF6F00);
  static const PdfColor _greyText = PdfColor.fromInt(0xFF555555);
  static const PdfColor _lightGrey = PdfColor.fromInt(0xFFF1F3F8);

  Future<Uint8List> buildInvoice({
    required CalculationRecord record,
    required String businessName,
    required String currencySymbol,
  }) async {
    final doc = pw.Document();
    final invoiceNo = 'INV-${record.dateTime.millisecondsSinceEpoch.toString().substring(5)}';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(businessName, invoiceNo, record),
              pw.SizedBox(height: 16),
              if (record.customerName != null) _buildCustomerRow(record.customerName!),
              if (record.customerName != null) pw.SizedBox(height: 12),
              _buildSizeCard(record),
              pw.SizedBox(height: 16),
              _buildPricingTable(record, currencySymbol),
              pw.SizedBox(height: 16),
              _buildGrandTotalBanner(record, currencySymbol),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHeader(String businessName, String invoiceNo, CalculationRecord record) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _navy,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                businessName,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Print Order Invoice',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                invoiceNo,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                AppFormatters.dateTime(record.dateTime),
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCustomerRow(String customerName) {
    return pw.Row(
      children: [
        pw.Text(
          'Customer: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: _greyText),
        ),
        pw.Text(customerName, style: const pw.TextStyle(fontSize: 11)),
      ],
    );
  }

  pw.Widget _buildSizeCard(CalculationRecord r) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _lightGrey,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PHOTO SIZE',
            style: pw.TextStyle(fontSize: 9, color: _greyText, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${AppFormatters.decimal2(r.width)} x ${AppFormatters.decimal2(r.height)} ${r.unit.shortLabel}',
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: _navy),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _miniStat('Sq. Inch', AppFormatters.decimal2(r.sqInch)),
              _miniStat('Sq. Feet', AppFormatters.decimal3(r.sqFeet)),
              _miniStat('Sq. Meter', AppFormatters.decimal3(r.sqMeter)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _miniStat(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 8, color: _greyText)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _buildPricingTable(CalculationRecord r, String currency) {
    pw.TableRow row(String label, String value, {bool bold = false}) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 5),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10.5,
                color: bold ? PdfColors.black : _greyText,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 5),
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10.5,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }

    return pw.Table(
      columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FlexColumnWidth(1.4)},
      children: [
        row('Rate (per Sq.Ft)', '$currency${AppFormatters.decimal2(r.rate)}'),
        row('Quantity', AppFormatters.decimal2(r.quantity)),
        pw.TableRow(children: [
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 6), child: pw.Divider(color: PdfColors.grey300)),
          pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 6), child: pw.Divider(color: PdfColors.grey300)),
        ]),
        row('Subtotal', '$currency${AppFormatters.decimal2(r.subtotal)}'),
        if (r.gstEnabled)
          row('GST (${AppFormatters.decimal2(r.gstPercent)}%)', '$currency${AppFormatters.decimal2(r.gstAmount)}'),
        if (r.roundOff)
          row('Round Off', '$currency${AppFormatters.decimal2(r.grandTotal - (r.subtotal + r.gstAmount))}'),
      ],
    );
  }

  pw.Widget _buildGrandTotalBanner(CalculationRecord r, String currency) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: pw.BoxDecoration(
        color: _orange,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'GRAND TOTAL',
            style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '$currency${AppFormatters.decimal2(r.grandTotal)}',
            style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 6),
        pw.Text(
          'Thank you for your business!',
          style: pw.TextStyle(fontSize: 9, color: _greyText, fontStyle: pw.FontStyle.italic),
        ),
        pw.Text(
          'Generated by Photo Print Calculator Pro',
          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey),
        ),
      ],
    );
  }

  /// Saves the generated PDF bytes into the app's documents directory and
  /// returns the absolute file path.
  Future<String> saveToDevice(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final invoicesDir = Directory('${dir.path}/invoices');
    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }
    final filePath = '${invoicesDir.path}/$fileName.pdf';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> shareInvoice(Uint8List bytes, String fileName) async {
    await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
  }

  Future<void> printInvoice(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }
}
