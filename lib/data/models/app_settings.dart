import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AppSettings {
  final String businessName;
  final String currencySymbol;
  final double gstPercent;
  final ThemeMode themeMode;
  final bool defaultGstEnabled;
  final bool defaultRoundOff;

  const AppSettings({
    required this.businessName,
    required this.currencySymbol,
    required this.gstPercent,
    required this.themeMode,
    required this.defaultGstEnabled,
    required this.defaultRoundOff,
  });

  factory AppSettings.defaults() => const AppSettings(
        businessName: AppConstants.defaultBusinessName,
        currencySymbol: AppConstants.defaultCurrencySymbol,
        gstPercent: AppConstants.defaultGstPercent,
        themeMode: ThemeMode.system,
        defaultGstEnabled: true,
        defaultRoundOff: false,
      );

  AppSettings copyWith({
    String? businessName,
    String? currencySymbol,
    double? gstPercent,
    ThemeMode? themeMode,
    bool? defaultGstEnabled,
    bool? defaultRoundOff,
  }) {
    return AppSettings(
      businessName: businessName ?? this.businessName,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      gstPercent: gstPercent ?? this.gstPercent,
      themeMode: themeMode ?? this.themeMode,
      defaultGstEnabled: defaultGstEnabled ?? this.defaultGstEnabled,
      defaultRoundOff: defaultRoundOff ?? this.defaultRoundOff,
    );
  }
}
