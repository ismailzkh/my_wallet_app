import 'package:flutter/material.dart';

import '../../core/utils/currency_utils.dart';
import '../../presentation/controllers/app_controllers.dart';
import '../../presentation/screens/main/main_navigation_screen.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter({
    required this.controller,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onCurrencyChanged,
  });

  final TransactionsController controller;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<AppCurrency> onCurrencyChanged;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case RouteNames.home:
      case RouteNames.dashboard:
        page = MainNavigationScreen(
          controller: controller,
          isDarkMode: isDarkMode,
          onThemeChanged: onThemeChanged,
          onCurrencyChanged: onCurrencyChanged,
        );
        break;

      default:
        page = MainNavigationScreen(
          controller: controller,
          isDarkMode: isDarkMode,
          onThemeChanged: onThemeChanged,
          onCurrencyChanged: onCurrencyChanged,
        );
        break;
    }

    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}