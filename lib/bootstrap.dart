import 'package:flutter/material.dart';

import 'app.dart';
import 'core/constants/settings_keys.dart';
import 'core/services/local_storage_service.dart';
import 'core/utils/currency_utils.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();
  await LocalStorageService.instance.reload();

  final bool isDarkMode =
      LocalStorageService.instance.getBool(SettingsKeys.isDarkMode) ?? true;

  final String savedCurrencyCode =
      LocalStorageService.instance.getString('settings.mainCurrencyCode') ?? 'IQD';

  final AppCurrency initialCurrency =
      savedCurrencyCode == 'USD' ? AppCurrency.usd : AppCurrency.iqd;

  CurrencyUtils.currentCurrency = initialCurrency;

  runApp(
    MyWalletApp(
      initialIsDarkMode: isDarkMode,
      initialCurrency: initialCurrency,
    ),
  );
}