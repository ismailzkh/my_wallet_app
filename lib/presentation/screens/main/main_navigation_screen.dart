import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../../controllers/app_controllers.dart';
import '../home/home_shell.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transactions_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onCurrencyChanged,
  });

  final TransactionsController controller;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<AppCurrency> onCurrencyChanged;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  AppCurrency _currentCurrency = CurrencyUtils.currentCurrency;

  void _handleCurrencyChanged(AppCurrency value) {
    setState(() {
      _currentCurrency = value;
      CurrencyUtils.currentCurrency = value;
    });

    widget.onCurrencyChanged(value);
  }

  void _openAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          controller: widget.controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeShell(
        key: ValueKey('home_$_currentCurrency'),
        transactionsController: widget.controller,
        onAddTransaction: _openAddTransaction,
        showLocalFab: false,
        showAppBarAddButton: true,
      ),
      TransactionsScreen(
        key: ValueKey('transactions_$_currentCurrency'),
        controller: widget.controller,
        onAddTransaction: _openAddTransaction,
      ),
      ReportsScreen(
        key: ValueKey('reports_$_currentCurrency'),
        controller: widget.controller,
      ),
      SettingsScreen(
        key: ValueKey('settings_${widget.isDarkMode}_$_currentCurrency'),
        controller: widget.controller,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
        onCurrencyChanged: _handleCurrencyChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? appColors.black : appColors.surface,
          border: Border(
            top: BorderSide(
              color: appColors.divider,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          backgroundColor: Colors.transparent,
          indicatorColor: appColors.surfaceAlt,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: appColors.textMuted,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: appColors.textPrimary,
                size: 22,
              ),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.receipt_long_outlined,
                color: appColors.textMuted,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.receipt_long_rounded,
                color: appColors.textPrimary,
                size: 22,
              ),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.bar_chart_outlined,
                color: appColors.textMuted,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.bar_chart_rounded,
                color: appColors.textPrimary,
                size: 22,
              ),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.settings_outlined,
                color: appColors.textMuted,
                size: 22,
              ),
              selectedIcon: Icon(
                Icons.settings_rounded,
                color: appColors.textPrimary,
                size: 22,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
