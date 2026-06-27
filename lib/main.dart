import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/home_shell.dart';
import 'presentation/providers/calculator_provider.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/providers/settings_provider.dart';

void main() {
  runApp(const PhotoPrintCalculatorApp());
}

class PhotoPrintCalculatorApp extends StatelessWidget {
  const PhotoPrintCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Photo Print Calculator Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.settings.themeMode,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
