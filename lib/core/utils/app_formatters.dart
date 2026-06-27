import 'package:intl/intl.dart';

/// Centralised formatting so every screen + the PDF invoice show numbers
/// in exactly the same style.
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _decimal2 = NumberFormat('#,##0.00');
  static final NumberFormat _decimal3 = NumberFormat('#,##0.000');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _dateOnly = DateFormat('dd MMM yyyy');

  static String currency(double value, String symbol) {
    return '$symbol${_decimal2.format(value)}';
  }

  static String decimal2(double value) => _decimal2.format(value);

  static String decimal3(double value) => _decimal3.format(value);

  static String dateTime(DateTime dt) => _dateTime.format(dt);

  static String dateOnly(DateTime dt) => _dateOnly.format(dt);
}
