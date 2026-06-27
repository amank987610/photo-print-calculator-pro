import '../../core/constants/app_constants.dart';

/// Represents a single saved calculation in history & is also the model
/// used to generate a PDF invoice.
class CalculationRecord {
  final String id;
  final String? customerName;
  final double width;
  final double height;
  final LengthUnit unit;
  final double sqInch;
  final double sqFeet;
  final double sqMeter;
  final double rate;
  final double quantity;
  final double subtotal;
  final bool gstEnabled;
  final double gstPercent;
  final double gstAmount;
  final bool roundOff;
  final double grandTotal;
  final DateTime dateTime;

  const CalculationRecord({
    required this.id,
    this.customerName,
    required this.width,
    required this.height,
    required this.unit,
    required this.sqInch,
    required this.sqFeet,
    required this.sqMeter,
    required this.rate,
    required this.quantity,
    required this.subtotal,
    required this.gstEnabled,
    required this.gstPercent,
    required this.gstAmount,
    required this.roundOff,
    required this.grandTotal,
    required this.dateTime,
  });

  CalculationRecord copyWith({
    String? id,
    String? customerName,
    double? width,
    double? height,
    LengthUnit? unit,
    double? sqInch,
    double? sqFeet,
    double? sqMeter,
    double? rate,
    double? quantity,
    double? subtotal,
    bool? gstEnabled,
    double? gstPercent,
    double? gstAmount,
    bool? roundOff,
    double? grandTotal,
    DateTime? dateTime,
  }) {
    return CalculationRecord(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      width: width ?? this.width,
      height: height ?? this.height,
      unit: unit ?? this.unit,
      sqInch: sqInch ?? this.sqInch,
      sqFeet: sqFeet ?? this.sqFeet,
      sqMeter: sqMeter ?? this.sqMeter,
      rate: rate ?? this.rate,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      gstEnabled: gstEnabled ?? this.gstEnabled,
      gstPercent: gstPercent ?? this.gstPercent,
      gstAmount: gstAmount ?? this.gstAmount,
      roundOff: roundOff ?? this.roundOff,
      grandTotal: grandTotal ?? this.grandTotal,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'width': width,
      'height': height,
      'unit': unit.name,
      'sqInch': sqInch,
      'sqFeet': sqFeet,
      'sqMeter': sqMeter,
      'rate': rate,
      'quantity': quantity,
      'subtotal': subtotal,
      'gstEnabled': gstEnabled ? 1 : 0,
      'gstPercent': gstPercent,
      'gstAmount': gstAmount,
      'roundOff': roundOff ? 1 : 0,
      'grandTotal': grandTotal,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory CalculationRecord.fromMap(Map<String, dynamic> map) {
    return CalculationRecord(
      id: map['id'] as String,
      customerName: map['customerName'] as String?,
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      unit: LengthUnitX.fromName(map['unit'] as String),
      sqInch: (map['sqInch'] as num).toDouble(),
      sqFeet: (map['sqFeet'] as num).toDouble(),
      sqMeter: (map['sqMeter'] as num).toDouble(),
      rate: (map['rate'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      gstEnabled: (map['gstEnabled'] as int) == 1,
      gstPercent: (map['gstPercent'] as num).toDouble(),
      gstAmount: (map['gstAmount'] as num).toDouble(),
      roundOff: (map['roundOff'] as int) == 1,
      grandTotal: (map['grandTotal'] as num).toDouble(),
      dateTime: DateTime.parse(map['dateTime'] as String),
    );
  }
}
