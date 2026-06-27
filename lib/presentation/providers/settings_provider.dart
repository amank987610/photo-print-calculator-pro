import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo = SettingsRepository();

  AppSettings _settings = AppSettings.defaults();
  bool _loaded = false;

  AppSettings get settings => _settings;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    _settings = await _repo.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> update(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await _repo.save(newSettings);
  }

  Future<void> updateBusinessName(String name) async {
    await update(_settings.copyWith(businessName: name));
  }

  Future<void> updateCurrencySymbol(String symbol) async {
    await update(_settings.copyWith(currencySymbol: symbol));
  }

  Future<void> updateGstPercent(double percent) async {
    await update(_settings.copyWith(gstPercent: percent));
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await update(_settings.copyWith(themeMode: mode));
  }

  Future<void> updateDefaultGstEnabled(bool value) async {
    await update(_settings.copyWith(defaultGstEnabled: value));
  }

  Future<void> updateDefaultRoundOff(bool value) async {
    await update(_settings.copyWith(defaultRoundOff: value));
  }
}
