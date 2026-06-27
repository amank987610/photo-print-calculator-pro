import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/calculator_engine.dart';
import '../../data/models/calculation_record.dart';
import '../../data/repositories/calculation_repository.dart';

/// Drives the main Calculator screen. Every setter immediately recomputes
/// area + price and notifies listeners so the live preview card updates
/// while the user is still typing - there is intentionally no "Calculate"
/// button anywhere in this app.
class CalculatorProvider extends ChangeNotifier {
  final CalculationRepository _repository = CalculationRepository();
  final _uuid = const Uuid();

  String? customerName;
  double width = 0;
  double height = 0;
  LengthUnit unit = LengthUnit.inch;
  double rate = 0;
  double quantity = 1;
  bool gstEnabled = true;
  double gstPercent = AppConstants.defaultGstPercent;
  bool roundOff = false;

  AreaResult area = AreaResult.zero;
  PriceResult price = PriceResult.zero;

  /// Call once after settings have loaded so the calculator starts with
  /// the shop owner's preferred GST%/toggle defaults.
  void applyDefaults({
    required bool defaultGstEnabled,
    required double defaultGstPercent,
    required bool defaultRoundOff,
  }) {
    gstEnabled = defaultGstEnabled;
    gstPercent = defaultGstPercent;
    roundOff = defaultRoundOff;
    _recalculate();
  }

  void setCustomerName(String? value) {
    customerName = value;
    notifyListeners();
  }

  void setWidth(double value) {
    width = value;
    _recalculate();
  }

  void setHeight(double value) {
    height = value;
    _recalculate();
  }

  void setUnit(LengthUnit value) {
    unit = value;
    _recalculate();
  }

  void setRate(double value) {
    rate = value;
    _recalculate();
  }

  void setQuantity(double value) {
    quantity = value <= 0 ? 1 : value;
    _recalculate();
  }

  void setGstEnabled(bool value) {
    gstEnabled = value;
    _recalculate();
  }

  void setGstPercent(double value) {
    gstPercent = value;
    _recalculate();
  }

  void setRoundOff(bool value) {
    roundOff = value;
    _recalculate();
  }

  void _recalculate() {
    area = CalculatorEngine.calculateArea(width: width, height: height, unit: unit);
    price = CalculatorEngine.calculatePrice(
      sqFeet: area.sqFeet,
      ratePerSqFt: rate,
      quantity: quantity,
      gstEnabled: gstEnabled,
      gstPercent: gstPercent,
      roundOff: roundOff,
    );
    notifyListeners();
  }

  bool get hasValidInput => width > 0 && height > 0 && rate > 0 && quantity > 0;

  /// Builds a [CalculationRecord] from current state (new id + now as
  /// timestamp) and persists it. Returns the saved record so the UI can
  /// show a confirmation / jump straight to PDF generation.
  Future<CalculationRecord> saveToHistory() async {
    final record = CalculationRecord(
      id: _uuid.v4(),
      customerName: (customerName == null || customerName!.trim().isEmpty)
          ? null
          : customerName!.trim(),
      width: width,
      height: height,
      unit: unit,
      sqInch: area.sqInch,
      sqFeet: area.sqFeet,
      sqMeter: area.sqMeter,
      rate: rate,
      quantity: quantity,
      subtotal: price.subtotal,
      gstEnabled: gstEnabled,
      gstPercent: gstPercent,
      gstAmount: price.gstAmount,
      roundOff: roundOff,
      grandTotal: price.grandTotal,
      dateTime: DateTime.now(),
    );
    await _repository.insert(record);
    return record;
  }

  /// Resets the calculator back to a blank slate while keeping the
  /// shop's GST/round-off defaults intact - used after saving so the
  /// owner can move on to the next customer's order quickly.
  void resetForNextEntry({
    required bool defaultGstEnabled,
    required double defaultGstPercent,
    required bool defaultRoundOff,
  }) {
    customerName = null;
    width = 0;
    height = 0;
    rate = 0;
    quantity = 1;
    unit = LengthUnit.inch;
    gstEnabled = defaultGstEnabled;
    gstPercent = defaultGstPercent;
    roundOff = defaultRoundOff;
    _recalculate();
  }
}
