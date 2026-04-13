import 'package:flutter/material.dart';

import '../../../core/constants/settings_keys.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_utils.dart';
import '../recurring/recurring_transactions_screen.dart';
import '../../controllers/app_controllers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
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
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _biometricLock = false;
  AppCurrency _selectedCurrency = CurrencyUtils.currentCurrency;

  @override
  void initState() {
    super.initState();
    _loadLocalSettings();
  }

  Future<void> _loadLocalSettings() async {
    final storage = LocalStorageService.instance;
    await storage.reload();

    final notifications =
        storage.getBool(SettingsKeys.notificationsEnabled) ?? true;
    final biometric =
        storage.getBool(SettingsKeys.biometricLockEnabled) ?? false;
    final savedCurrencyCode =
        storage.getString('settings.mainCurrencyCode') ?? 'IQD';

    if (!mounted) return;

    setState(() {
      _notifications = notifications;
      _biometricLock = biometric;
      _selectedCurrency =
          savedCurrencyCode == 'USD' ? AppCurrency.usd : AppCurrency.iqd;
      CurrencyUtils.currentCurrency = _selectedCurrency;
    });
  }

  Future<void> _setNotifications(bool value) async {
    setState(() {
      _notifications = value;
    });

    await LocalStorageService.instance.setBool(
      SettingsKeys.notificationsEnabled,
      value,
    );
  }

  Future<void> _setBiometricLock(bool value) async {
    setState(() {
      _biometricLock = value;
    });

    await LocalStorageService.instance.setBool(
      SettingsKeys.biometricLockEnabled,
      value,
    );
  }

  Future<void> _setCurrency(AppCurrency value) async {
    setState(() {
      _selectedCurrency = value;
      CurrencyUtils.currentCurrency = value;
    });

    await LocalStorageService.instance.setString(
      'settings.mainCurrencyCode',
      value == AppCurrency.iqd ? 'IQD' : 'USD',
    );
    widget.onCurrencyChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const _LeadingIconTile(
                    icon: Icons.notifications_none_rounded,
                  ),
                  title: const Text('Notifications'),
                  subtitle: const Text('Receive reminders and alerts'),
                  value: _notifications,
                  activeThumbColor: appColors.black,
                  activeTrackColor: appColors.green,
                  inactiveThumbColor: appColors.textMuted,
                  inactiveTrackColor: appColors.surfaceAlt,
                  onChanged: _setNotifications,
                ),
                Divider(height: 1, color: appColors.divider),
                SwitchListTile(
                  secondary: const _LeadingIconTile(
                    icon: Icons.dark_mode_outlined,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark appearance'),
                  value: widget.isDarkMode,
                  activeThumbColor: appColors.black,
                  activeTrackColor: appColors.green,
                  inactiveThumbColor: appColors.textMuted,
                  inactiveTrackColor: appColors.surfaceAlt,
                  onChanged: widget.onThemeChanged,
                ),
                Divider(height: 1, color: appColors.divider),
                SwitchListTile(
                  secondary: const _LeadingIconTile(
                    icon: Icons.fingerprint_rounded,
                  ),
                  title: const Text('Biometric Lock'),
                  subtitle: const Text('Protect app with fingerprint or face'),
                  value: _biometricLock,
                  activeThumbColor: appColors.black,
                  activeTrackColor: appColors.green,
                  inactiveThumbColor: appColors.textMuted,
                  inactiveTrackColor: appColors.surfaceAlt,
                  onChanged: _setBiometricLock,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<AppCurrency>(
            initialValue: _selectedCurrency,
            dropdownColor: appColors.surface,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: appColors.textSecondary,
              size: 20,
            ),
            decoration: const InputDecoration(
              labelText: 'Currency',
              prefixIcon: Icon(Icons.payments_rounded),
              helperText: 'IQD is the default main currency',
            ),
            items: const [
              DropdownMenuItem(
                value: AppCurrency.iqd,
                child: Text('Iraqi Dinar (IQD)'),
              ),
              DropdownMenuItem(
                value: AppCurrency.usd,
                child: Text('US Dollar (USD)'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              _setCurrency(value);
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const _LeadingIconTile(
              icon: Icons.repeat_rounded,
            ),
            title: const Text('Recurring transactions'),
            subtitle: const Text('Pause or delete repeating items'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecurringTransactionsScreen(
                    controller: widget.controller,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LeadingIconTile extends StatelessWidget {
  const _LeadingIconTile({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: appColors.textPrimary,
        size: 20,
      ),
    );
  }
}
