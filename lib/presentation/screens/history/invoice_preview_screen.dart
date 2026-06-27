import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../data/models/calculation_record.dart';
import '../../../services/pdf_service.dart';
import '../../providers/settings_provider.dart';

/// Shows the generated invoice PDF inline (using the `printing` package's
/// built-in [PdfPreview] widget) with Save / Share / Print actions, as
/// required by spec.
class InvoicePreviewScreen extends StatefulWidget {
  final CalculationRecord record;

  const InvoicePreviewScreen({super.key, required this.record});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  final _pdfService = PdfService();
  Uint8List? _bytes;
  bool _saving = false;

  String get _fileName {
    final r = widget.record;
    final safeCustomer = (r.customerName ?? 'order').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'Invoice_${safeCustomer}_${r.dateTime.millisecondsSinceEpoch}';
  }

  Future<Uint8List> _generate(BuildContext context) async {
    if (_bytes != null) return _bytes!;
    final settings = context.read<SettingsProvider>().settings;
    final bytes = await _pdfService.buildInvoice(
      record: widget.record,
      businessName: settings.businessName,
      currencySymbol: settings.currencySymbol,
    );
    _bytes = bytes;
    return bytes;
  }

  Future<void> _saveToDevice(BuildContext context) async {
    setState(() => _saving = true);
    try {
      final bytes = await _generate(context);
      final path = await _pdfService.saveToDevice(bytes, _fileName);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved: $path')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          IconButton(
            tooltip: 'Save to device',
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_alt_outlined),
            onPressed: _saving ? null : () => _saveToDevice(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generate(context),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: '$_fileName.pdf',
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.save_alt_outlined),
            onPressed: (context, build, pageFormat) => _saveToDevice(context),
          ),
        ],
      ),
    );
  }
}
