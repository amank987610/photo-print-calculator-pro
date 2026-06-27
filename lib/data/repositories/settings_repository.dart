import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(AppConstants.prefThemeMode);
    final themeMode = themeIndex != null && themeIndex < ThemeMode.values.length
        ? ThemeMode.values[themeIndex]
        : ThemeMode.system;

    return AppSettings(
      businessName: prefs.getString(AppConstants.prefBusinessName) ??
          AppConstants.defaultBusinessName,
      currencySymbol: prefs.getString(AppConstants.prefCurrencySymbol) ??
          AppConstants.defaultCurrencySymbol,
      gstPercent: prefs.getDouble(AppConstants.prefGstPercent) ??
          AppConstants.defaultGstPercent,
      themeMode: themeMode,
      defaultGstEnabled: prefs.getBool(AppConstants.prefDefaultGstEnabled) ?? true,
      defaultRoundOff: prefs.getBool(AppConstants.prefDefaultRoundOff) ?? false,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefBusinessName, settings.businessName);
    await prefs.setString(AppConstants.prefCurrencySymbol, settings.currencySymbol);
    await prefs.setDouble(AppConstants.prefGstPercent, settings.gstPercent);
    await prefs.setInt(AppConstants.prefThemeMode, settings.themeMode.index);
    await prefs.setBool(AppConstants.prefDefaultGstEnabled, settings.defaultGstEnabled);
    await prefs.setBool(AppConstants.prefDefaultRoundOff, settings.defaultRoundOff);
  }
}
