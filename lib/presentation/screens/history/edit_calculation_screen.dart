import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/calculator_engine.dart';
import '../../../data/models/calculation_record.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/labeled_number_field.dart';
import '../../widgets/live_preview_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/unit_selector.dart';

/// Lets the shop owner correct a mistake in a previously saved order
/// (e.g. wrong rate typed, wrong size) without having to delete + re-enter
/// it from scratch.
class EditCalculationScreen extends StatefulWidget {
  final CalculationRecord record;

  const EditCalculationScreen({super.key, required this.record});

  @override
  State<EditCalculationScreen> createState() => _EditCalculationScreenState();
}

class _EditCalculationScreenState extends State<EditCalculationScreen> {
  late TextEditingController _customerController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _rateController;
  late TextEditingController _quantityController;
  late TextEditingController _gstPercentController;

  late double _width;
  late double _height;
  late LengthUnit _unit;
  late double _rate;
  late double _quantity;
  late bool _gstEnabled;
  late double _gstPercent;
  late bool _roundOff;

  AreaResult _area = AreaResult.zero;
  PriceResult _price = PriceResult.zero;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _customerController = TextEditingController(text: r.customerName ?? '');
    _widthController = TextEditingController(text: _trimZero(r.width));
    _heightController = TextEditingController(text: _trimZero(r.height));
    _rateController = TextEditingController(text: _trimZero(r.rate));
    _quantityController = TextEditingController(text: _trimZero(r.quantity));
    _gstPercentController = TextEditingController(text: _trimZero(r.gstPercent));

    _width = r.width;
    _height = r.height;
    _unit = r.unit;
    _rate = r.rate;
    _quantity = r.quantity;
    _gstEnabled = r.gstEnabled;
    _gstPercent = r.gstPercent;
    _roundOff = r.roundOff;
    _recalculate();
  }

  String _trimZero(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  void _recalculate() {
    _area = CalculatorEngine.calculateArea(width: _width, height: _height, unit: _unit);
    _price = CalculatorEngine.calculatePrice(
      sqFeet: _area.sqFeet,
      ratePerSqFt: _rate,
      quantity: _quantity,
      gstEnabled: _gstEnabled,
      gstPercent: _gstPercent,
      roundOff: _roundOff,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _customerController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _rateController.dispose();
    _quantityController.dispose();
    _gstPercentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_width <= 0 || _height <= 0 || _rate <= 0 || _quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Width, Height, Rate and Quantity must be greater than 0.')),
      );
      return;
    }

    final updated = widget.record.copyWith(
      customerName: _customerController.text.trim().isEmpty ? null : _customerController.text.trim(),
      width: _width,
      height: _height,
      unit: _unit,
      sqInch: _area.sqInch,
      sqFeet: _area.sqFeet,
      sqMeter: _area.sqMeter,
      rate: _rate,
      quantity: _quantity,
      subtotal: _price.subtotal,
      gstEnabled: _gstEnabled,
      gstPercent: _gstPercent,
      gstAmount: _price.gstAmount,
      roundOff: _roundOff,
      grandTotal: _price.grandTotal,
    );

    await context.read<HistoryProvider>().updateRecord(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calculation updated ✅')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsProvider>().settings.currencySymbol;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Calculation')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            LivePreviewCard(
              width: _width,
              height: _height,
              unit: _unit,
              area: _area,
              rate: _rate,
              quantity: _quantity,
              gstEnabled: _gstEnabled,
              gstPercent: _gstPercent,
              price: _price,
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
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: LabeledNumberField(
                          label: 'Width',
                          icon: Icons.straighten,
                          controller: _widthController,
                          onChanged: (v) {
                            _width = v;
                            _recalculate();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LabeledNumberField(
                          label: 'Height',
                          icon: Icons.height,
                          controller: _heightController,
                          onChanged: (v) {
                            _height = v;
                            _recalculate();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  UnitSelector(
                    selected: _unit,
                    onChanged: (u) {
                      _unit = u;
                      _recalculate();
                    },
                  ),
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
                          onChanged: (v) {
                            _rate = v;
                            _recalculate();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LabeledNumberField(
                          label: 'Quantity',
                          icon: Icons.numbers,
                          controller: _quantityController,
                          allowDecimal: false,
                          onChanged: (v) {
                            _quantity = v <= 0 ? 1 : v;
                            _recalculate();
                          },
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Apply GST'),
                    value: _gstEnabled,
                    onChanged: (v) {
                      _gstEnabled = v;
                      _recalculate();
                    },
                  ),
                  if (_gstEnabled)
                    LabeledNumberField(
                      label: 'GST %',
                      icon: Icons.percent,
                      controller: _gstPercentController,
                      onChanged: (v) {
                        _gstPercent = v;
                        _recalculate();
                      },
                    ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Round Off Total'),
                    value: _roundOff,
                    onChanged: (v) {
                      _roundOff = v;
                      _recalculate();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Update Calculation'),
          ),
        ),
      ),
    );
  }
}
