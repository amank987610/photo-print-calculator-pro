import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/section_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _businessNameController;
  late TextEditingController _currencyController;
  late TextEditingController _gstController;
  bool _initialized = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _currencyController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _initControllers(SettingsProvider provider) {
    if (_initialized) return;
    _initialized = true;
    final s = provider.settings;
    _businessNameController = TextEditingController(text: s.businessName);
    _currencyController = TextEditingController(text: s.currencySymbol);
    _gstController = TextEditingController(text: s.gstPercent.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    _initControllers(provider);
    final settings = provider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              title: 'Business Details',
              icon: Icons.store_outlined,
              child: Column(
                children: [
                  TextField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      labelText: 'Business Name',
                      prefixIcon: Icon(Icons.storefront_outlined, size: 20),
                    ),
                    onSubmitted: (v) => provider.updateBusinessName(v.trim().isEmpty
                        ? AppConstants.defaultBusinessName
                        : v.trim()),
                    onEditingComplete: () => provider.updateBusinessName(
                      _businessNameController.text.trim().isEmpty
                          ? AppConstants.defaultBusinessName
                          : _businessNameController.text.trim(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => provider.updateBusinessName(
                        _businessNameController.text.trim().isEmpty
                            ? AppConstants.defaultBusinessName
                            : _businessNameController.text.trim(),
                      ),
                      child: const Text('Save Name'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Pricing Defaults',
              icon: Icons.tune,
              child: Column(
                children: [
                  TextField(
                    controller: _currencyController,
                    maxLength: 3,
                    decoration: const InputDecoration(
                      labelText: 'Currency Symbol',
                      prefixIcon: Icon(Icons.currency_exchange, size: 20),
                      counterText: '',
                    ),
                    onEditingComplete: () => provider.updateCurrencySymbol(
                      _currencyController.text.trim().isEmpty
                          ? AppConstants.defaultCurrencySymbol
                          : _currencyController.text.trim(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _gstController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Default GST %',
                      prefixIcon: Icon(Icons.percent, size: 20),
                    ),
                    onEditingComplete: () => provider.updateGstPercent(
                      double.tryParse(_gstController.text) ?? AppConstants.defaultGstPercent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('GST applied by default'),
                    value: settings.defaultGstEnabled,
                    onChanged: provider.updateDefaultGstEnabled,
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Round off total by default'),
                    value: settings.defaultRoundOff,
                    onChanged: provider.updateDefaultRoundOff,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Appearance',
              icon: Icons.palette_outlined,
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: settings.themeMode,
                    onChanged: (v) => provider.updateThemeMode(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: settings.themeMode,
                    onChanged: (v) => provider.updateThemeMode(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('System Default'),
                    value: ThemeMode.system,
                    groupValue: settings.themeMode,
                    onChanged: (v) => provider.updateThemeMode(v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'About',
              icon: Icons.info_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 12.5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppConstants.appTagline,
                    style: TextStyle(fontSize: 13.5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Built for photo studios, print houses, flex printing shops, '
                    'wedding photographers, frame shops and digital printing '
                    'businesses. 100% offline — your data never leaves this device.',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
