import 'package:flutter/material.dart';

import 'core/constants/settings_keys.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';
import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/currency_utils.dart';
import 'data/repositories/app_repository_impls.dart';
import 'domain/usecases/app_usecases.dart';
import 'presentation/controllers/app_controllers.dart';

class MyWalletApp extends StatefulWidget {
  const MyWalletApp({
    super.key,
    required this.initialIsDarkMode,
    required this.initialCurrency,
  });

  final bool initialIsDarkMode;
  final AppCurrency initialCurrency;

  @override
  State<MyWalletApp> createState() => _MyWalletAppState();
}

class _MyWalletAppState extends State<MyWalletApp> {
  late final TransactionsRepositoryImpl _repository;
  late final GetTransactionsUseCase _getTransactionsUseCase;
  late final AddTransactionUseCase _addTransactionUseCase;
  late final DeleteTransactionUseCase _deleteTransactionUseCase;
  late final UpdateTransactionUseCase _updateTransactionUseCase;
  late final GetTotalBalanceUseCase _getTotalBalanceUseCase;
  late final GetTotalIncomeUseCase _getTotalIncomeUseCase;
  late final GetTotalExpenseUseCase _getTotalExpenseUseCase;
  late final TransactionsController _controller;

  bool _isDarkMode = true;
  late AppCurrency _currentCurrency;

  final ValueNotifier<bool> _themeNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();

    _isDarkMode = widget.initialIsDarkMode;
    _themeNotifier.value = _isDarkMode;

    _currentCurrency = widget.initialCurrency;
    CurrencyUtils.currentCurrency = _currentCurrency;

    _repository = TransactionsRepositoryImpl();

    _getTransactionsUseCase = GetTransactionsUseCase(_repository);
    _addTransactionUseCase = AddTransactionUseCase(_repository);
    _deleteTransactionUseCase = DeleteTransactionUseCase(_repository);
    _updateTransactionUseCase = UpdateTransactionUseCase(_repository);
    _getTotalBalanceUseCase = GetTotalBalanceUseCase(_repository);
    _getTotalIncomeUseCase = GetTotalIncomeUseCase(_repository);
    _getTotalExpenseUseCase = GetTotalExpenseUseCase(_repository);

    _controller = TransactionsController(
      getTransactionsUseCase: _getTransactionsUseCase,
      addTransactionUseCase: _addTransactionUseCase,
      deleteTransactionUseCase: _deleteTransactionUseCase,
      updateTransactionUseCase: _updateTransactionUseCase,
      getTotalBalanceUseCase: _getTotalBalanceUseCase,
      getTotalIncomeUseCase: _getTotalIncomeUseCase,
      getTotalExpenseUseCase: _getTotalExpenseUseCase,
    );

    _controller.loadTransactions();
  }

  Future<void> _handleThemeChanged(bool value) async {
    _themeNotifier.value = value;

    if (mounted) {
      setState(() {
        _isDarkMode = value;
      });
    }

    await LocalStorageService.instance.setBool(
      SettingsKeys.isDarkMode,
      value,
    );
  }

  Future<void> _handleCurrencyChanged(AppCurrency value) async {
    if (!mounted) return;

    setState(() {
      _currentCurrency = value;
      CurrencyUtils.currentCurrency = value;
    });
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _themeNotifier,
      builder: (context, isDark, _) {
        final appRouter = AppRouter(
          controller: _controller,
          isDarkMode: isDark,
          onThemeChanged: _handleThemeChanged,
          onCurrencyChanged: _handleCurrencyChanged,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Wallet App',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: RouteNames.home,
          onGenerateRoute: appRouter.onGenerateRoute,
        );
      },
    );
  }
}