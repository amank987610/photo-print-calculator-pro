/// Centralised constants used across the app so magic numbers / strings
/// never get scattered across screens & widgets.
library;

enum LengthUnit { inch, cm, mm, feet }

extension LengthUnitX on LengthUnit {
  String get label {
    switch (this) {
      case LengthUnit.inch:
        return 'Inch';
      case LengthUnit.cm:
        return 'CM';
      case LengthUnit.mm:
        return 'MM';
      case LengthUnit.feet:
        return 'Feet';
    }
  }

  String get shortLabel {
    switch (this) {
      case LengthUnit.inch:
        return 'in';
      case LengthUnit.cm:
        return 'cm';
      case LengthUnit.mm:
        return 'mm';
      case LengthUnit.feet:
        return 'ft';
    }
  }

  /// Conversion factor to get from this unit to **inches**.
  double get toInchFactor {
    switch (this) {
      case LengthUnit.inch:
        return 1.0;
      case LengthUnit.cm:
        return 0.393701;
      case LengthUnit.mm:
        return 0.0393701;
      case LengthUnit.feet:
        return 12.0;
    }
  }

  static LengthUnit fromName(String name) {
    return LengthUnit.values.firstWhere(
      (e) => e.name == name,
      orElse: () => LengthUnit.inch,
    );
  }
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Photo Print Calculator Pro';
  static const String appTagline = 'Instant Print Area & Price Calculator';

  // Database
  static const String dbName = 'photo_print_calculator.db';
  static const int dbVersion = 1;
  static const String tableCalculations = 'calculations';

  // Shared preferences keys
  static const String prefBusinessName = 'pref_business_name';
  static const String prefCurrencySymbol = 'pref_currency_symbol';
  static const String prefGstPercent = 'pref_gst_percent';
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefDefaultGstEnabled = 'pref_default_gst_enabled';
  static const String prefDefaultRoundOff = 'pref_default_round_off';

  // Defaults
  static const String defaultBusinessName = 'Shri Print House';
  static const String defaultCurrencySymbol = '₹';
  static const double defaultGstPercent = 18.0;

  // Conversion constants
  static const double sqInchToSqFeet = 1 / 144.0;
  static const double sqInchToSqMeter = 0.00064516;
}
