import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/app_settings.dart';
import '../../providers/calculator_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/labeled_number_field.dart';
import '../../widgets/live_preview_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/unit_selector.dart';
import '../history/invoice_preview_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _customerController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _rateController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _gstPercentController = TextEditingController();

  bool _defaultsApplied = false;
  VoidCallback? _settingsLoadedListener;

  @override
  void initState() {
    super.initState();
    // Defaults are synced once Settings finish loading, but never
    // synchronously from build() - notifyListeners() during a build pass
    // would trigger Flutter's "setState called during build" error since
    // this screen also listens to CalculatorProvider.
    WidgetsBinding.instance.addPostFrameCallback((_) => _trySyncDefaults());
  }

  @override
  void dispose() {
    if (_settingsLoadedListener != null) {
      context.read<SettingsProvider>().removeListener(_settingsLoadedListener!);
    }
    _customerController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _rateController.dispose();
    _quantityController.dispose();
    _gstPercentController.dispose();
    super.dispose();
  }

  void _trySyncDefaults() {
    if (_defaultsApplied || !mounted) return;
    final settingsProvider = context.read<SettingsProvider>();

    if (settingsProvider.isLoaded) {
      _applyDefaults(settingsProvider.settings);
    } else {
      _settingsLoadedListener = () {
        if (settingsProvider.isLoaded) {
          settingsProvider.removeListener(_settingsLoadedListener!);
          _settingsLoadedListener = null;
          _applyDefaults(settingsProvider.settings);
        }
      };
      settingsProvider.addListener(_settingsLoadedListener!);
    }
  }

  void _applyDefaults(AppSettings settings) {
    if (_defaultsApplied || !mounted) return;
    _defaultsApplied = true;
    final calc = context.read<CalculatorProvider>();
    calc.applyDefaults(
      defaultGstEnabled: settings.defaultGstEnabled,
      defaultGstPercent: settings.gstPercent,
      defaultRoundOff: settings.defaultRoundOff,
    );
    setState(() {
      _gstPercentController.text = calc.gstPercent.toStringAsFixed(0);
    });
  }

  Future<void> _saveAndReset(BuildContext context, {bool openInvoice = false}) async {
    final calc = context.read<CalculatorProvider>();
    final history = context.read<HistoryProvider>();
    final settings = context.read<SettingsProvider>().settings;

    if (!calc.hasValidInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Width, Height and Rate to save.')),
      );
      return;
    }

    final record = await calc.saveToHistory();
    await history.load();

    if (!context.mounted) return;

    if (openInvoice) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => InvoicePreviewScreen(record: record)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calculation saved to History ✅')),
      );
    }

    calc.resetForNextEntry(
      defaultGstEnabled: settings.defaultGstEnabled,
      defaultGstPercent: settings.gstPercent,
      defaultRoundOff: settings.defaultRoundOff,
    );
    _customerController.clear();
    _widthController.clear();
    _heightController.clear();
    _rateController.clear();
    _quantityController.text = '1';
    _gstPercentController.text = settings.gstPercent.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final calc = context.watch<CalculatorProvider>();

    final currency = settings.settings.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            LivePreviewCard(
              width: calc.width,
              height: calc.height,
              unit: calc.unit,
              area: calc.area,
              rate: calc.rate,
              quantity: calc.quantity,
              gstEnabled: calc.gstEnabled,
              gstPercent: calc.gstPercent,
              price: calc.price,
              currencySymbol: currency,
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Photo Size',
              icon: Icons.photo_size_select_large_outlined,
              child: Column(
                children: [
                  TextField(
                    controller: _customerController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name (optional)',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    onChanged: calc.setCustomerName,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: LabeledNumberField(
                          label: 'Width',
                          icon: Icons.straighten,
                          controller: _widthController,
                          onChanged: calc.setWidth,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LabeledNumberField(
                          label: 'Height',
                          icon: Icons.height,
                          controller: _heightController,
                          onChanged: calc.setHeight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  UnitSelector(selected: calc.unit, onChanged: calc.setUnit),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Pricing',
              icon: Icons.currency_rupee,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LabeledNumberField(
                          label: 'Rate / Sq.Ft',
                          icon: Icons.sell_outlined,
                          suffixText: currency,
                          controller: _rateController,
                          onChanged: calc.setRate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LabeledNumberField(
                          label: 'Quantity',
                          icon: Icons.numbers,
                          controller: _quantityController,
                          allowDecimal: false,
                          onChanged: (v) => calc.setQuantity(v <= 0 ? 1 : v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Apply GST'),
                    value: calc.gstEnabled,
                    onChanged: calc.setGstEnabled,
                  ),
                  if (calc.gstEnabled) ...[
                    const SizedBox(height: 8),
                    LabeledNumberField(
                      label: 'GST %',
                      icon: Icons.percent,
                      controller: _gstPercentController,
                      onChanged: calc.setGstPercent,
                    ),
                  ],
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Round Off Total'),
                    value: calc.roundOff,
                    onChanged: calc.setRoundOff,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _saveAndReset(context),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => _saveAndReset(context, openInvoice: true),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Save & Generate PDF'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
