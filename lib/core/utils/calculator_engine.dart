import '../constants/app_constants.dart';

/// Result of converting a raw width/height + unit into all the area units
/// the app needs to display simultaneously.
class AreaResult {
  final double sqInch;
  final double sqFeet;
  final double sqMeter;

  const AreaResult({
    required this.sqInch,
    required this.sqFeet,
    required this.sqMeter,
  });

  static const zero = AreaResult(sqInch: 0, sqFeet: 0, sqMeter: 0);
}

/// Result of the full pricing calculation.
class PriceResult {
  final double subtotal;
  final double gstAmount;
  final double grandTotalBeforeRound;
  final double grandTotal;
  final double roundOffDifference;

  const PriceResult({
    required this.subtotal,
    required this.gstAmount,
    required this.grandTotalBeforeRound,
    required this.grandTotal,
    required this.roundOffDifference,
  });

  static const zero = PriceResult(
    subtotal: 0,
    gstAmount: 0,
    grandTotalBeforeRound: 0,
    grandTotal: 0,
    roundOffDifference: 0,
  );
}

/// Pure, stateless calculation helpers. Kept separate from UI/DB so they're
/// trivially unit-testable and reusable (calculator screen, PDF service,
/// and history edit screen all rely on the exact same math).
class CalculatorEngine {
  CalculatorEngine._();

  /// Converts [width] x [height] (given in [unit]) into square inch,
  /// square feet and square meter.
  static AreaResult calculateArea({
    required double width,
    required double height,
    required LengthUnit unit,
  }) {
    if (width <= 0 || height <= 0) return AreaResult.zero;

    final widthInInch = width * unit.toInchFactor;
    final heightInInch = height * unit.toInchFactor;
    final sqInch = widthInInch * heightInInch;

    final sqFeet = sqInch * AppConstants.sqInchToSqFeet;
    final sqMeter = sqInch * AppConstants.sqInchToSqMeter;

    return AreaResult(sqInch: sqInch, sqFeet: sqFeet, sqMeter: sqMeter);
  }

  /// Computes subtotal -> GST -> grand total -> optional round off.
  ///
  /// Pricing is always calculated on **square feet** (the universal unit
  /// used by the printing/flex industry for rate cards), regardless of
  /// which unit the user typed the dimensions in.
  static PriceResult calculatePrice({
    required double sqFeet,
    required double ratePerSqFt,
    required double quantity,
    required bool gstEnabled,
    required double gstPercent,
    required bool roundOff,
  }) {
    if (sqFeet <= 0 || ratePerSqFt < 0 || quantity <= 0) {
      return PriceResult.zero;
    }

    final subtotal = sqFeet * ratePerSqFt * quantity;
    final gstAmount = gstEnabled ? (subtotal * gstPercent / 100.0) : 0.0;
    final grandTotalBeforeRound = subtotal + gstAmount;

    double grandTotal = grandTotalBeforeRound;
    double diff = 0.0;
    if (roundOff) {
      grandTotal = grandTotalBeforeRound.roundToDouble();
      diff = grandTotal - grandTotalBeforeRound;
    }

    return PriceResult(
      subtotal: subtotal,
      gstAmount: gstAmount,
      grandTotalBeforeRound: grandTotalBeforeRound,
      grandTotal: grandTotal,
      roundOffDifference: diff,
    );
  }
}
