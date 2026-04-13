import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/currency_utils.dart';

const String kTxKey = 'transactions';
const String kAccountsKey = 'accounts';

class HomePage extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.isDarkTheme,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class WalletTransaction {
  final String title;
  final double amount;
  final String category;
  final String account;
  final DateTime date;

  WalletTransaction({
    required this.title,
    required this.amount,
    required this.category,
    required this.account,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'category': category,
        'account': account,
        'date': date.toIso8601String(),
      };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      account: json['account'] as String? ?? 'Main',
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<WalletTransaction> _transactions = [];
  final List<String> _accounts = ['Main'];

  String _searchQuery = '';
  String _filterType = 'all';
  String _filterAccount = 'all';
  String _filterCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.get(kTxKey);
    List<String> txStringList = [];

    if (raw is List<String>) {
      txStringList = raw;
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          txStringList = decoded.map((e) => e.toString()).toList();
        } else {
          txStringList = [raw];
        }
      } catch (_) {
        txStringList = [];
      }
      await prefs.setStringList(kTxKey, txStringList);
    }

    final loadedTx = txStringList
        .map((e) => WalletTransaction.fromJson(jsonDecode(e)))
        .toList();

    final accList = prefs.getStringList(kAccountsKey) ?? ['Main'];

    if (!mounted) return;
    setState(() {
      _transactions
        ..clear()
        ..addAll(loadedTx);
      _accounts
        ..clear()
        ..addAll(accList.isEmpty ? ['Main'] : accList);
    });
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _transactions.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(kTxKey, list);
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(kAccountsKey, _accounts);
  }

  void _onAddTransactionPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _TransactionForm(
          accounts: _accounts,
          onSubmit: (tx) async {
            setState(() {
              _transactions.insert(0, tx);
            });
            await _saveTransactions();
          },
        );
      },
    );
  }

  void _addAccount() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add account'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Account name',
            hintText: 'e.g. Tinkoff, Cash, Sber',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      setState(() {
        if (!_accounts.contains(name)) {
          _accounts.add(name);
        }
      });
      await _saveAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Wallet'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => widget.onThemeChanged(!isDark),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: _onAddTransactionPressed,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildTransactionsTab();
      case 2:
        return _buildReportsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab() {
    final total = _transactions.fold<double>(0, (prev, t) => prev + t.amount);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Total balance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyUtils.format(total),
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accounts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: _addAccount,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _accounts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final acc = _accounts[index];
                final accTotal = _transactions
                    .where((t) => t.account == acc)
                    .fold<double>(0, (p, t) => p + t.amount);

                return Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        acc,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        CurrencyUtils.format(accTotal),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent transactions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(
                child: Text('No transactions yet. Tap + to add one.'),
              ),
            )
          else
            ..._transactions.take(5).map((tx) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Text(
                    tx.category.isNotEmpty
                        ? tx.category.characters.first.toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(tx.title),
                subtitle: Text(
                  '${tx.category} • ${tx.account} • ${_formatDate(tx.date)}',
                ),
                trailing: Text(
                  CurrencyUtils.format(tx.amount),
                  style: TextStyle(
                    color: tx.amount >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  List<WalletTransaction> get _filteredTransactions {
    return _transactions.where((t) {
      final q = _searchQuery;
      final matchesSearch = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.account.toLowerCase().contains(q);

      final matchesType = switch (_filterType) {
        'income' => t.amount >= 0,
        'expense' => t.amount < 0,
        _ => true,
      };

      final matchesAccount =
          _filterAccount == 'all' || t.account == _filterAccount;
      final matchesCategory =
          _filterCategory == 'all' || t.category == _filterCategory;

      return matchesSearch &&
          matchesType &&
          matchesAccount &&
          matchesCategory;
    }).toList();
  }

  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Text('No transactions. Tap + to add your first one.'),
      );
    }

    final visible = _filteredTransactions;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by title, category, account',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: _filterType,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All'),
                        ),
                        DropdownMenuItem(
                          value: 'income',
                          child: Text('Income'),
                        ),
                        DropdownMenuItem(
                          value: 'expense',
                          child: Text('Expense'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _filterType = value);
                      },
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _filterAccount,
                      underline: const SizedBox(),
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('All accounts'),
                        ),
                        ..._accounts.map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text(a),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _filterAccount = value);
                      },
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _filterCategory,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All categories'),
                        ),
                        DropdownMenuItem(
                          value: 'General',
                          child: Text('General'),
                        ),
                        DropdownMenuItem(
                          value: 'Food',
                          child: Text('Food'),
                        ),
                        DropdownMenuItem(
                          value: 'Transport',
                          child: Text('Transport'),
                        ),
                        DropdownMenuItem(
                          value: 'Bills',
                          child: Text('Bills'),
                        ),
                        DropdownMenuItem(
                          value: 'Salary',
                          child: Text('Salary'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _filterCategory = value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: visible.isEmpty
              ? const Center(
                  child: Text('No transactions match your filters.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = visible[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          tx.category.isNotEmpty
                              ? tx.category.characters.first.toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(tx.title),
                      subtitle: Text(
                        '${tx.category} • ${tx.account} • ${_formatDate(tx.date)}',
                      ),
                      trailing: Text(
                        CurrencyUtils.format(tx.amount),
                        style: TextStyle(
                          color: tx.amount >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Text('Add some transactions to see reports.'),
      );
    }

    double income = 0;
    double expenses = 0;
    final Map<String, double> expensesByCategory = {};
    final Map<String, double> totalsByAccount = {};

    for (final t in _transactions) {
      totalsByAccount.update(
        t.account,
        (value) => value + t.amount,
        ifAbsent: () => t.amount,
      );

      if (t.amount >= 0) {
        income += t.amount;
      } else {
        expenses += t.amount;
        final key = t.category.isEmpty ? 'Other' : t.category;
        expensesByCategory.update(
          key,
          (value) => value + t.amount.abs(),
          ifAbsent: () => t.amount.abs(),
        );
      }
    }

    final totalExpensesAbs =
        expensesByCategory.values.fold<double>(0, (p, v) => p + v);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: ListTile(
                    title: const Text('Income'),
                    subtitle: Text(
                      CurrencyUtils.format(income),
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: ListTile(
                    title: const Text('Expenses'),
                    subtitle: Text(
                      CurrencyUtils.format(expenses),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Card(
            child: ListTile(
              title: const Text('Net'),
              subtitle: Text(CurrencyUtils.format(income + expenses)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Expenses by category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: expensesByCategory.isEmpty
                ? const Center(
                    child: Text('No expenses yet to show in chart.'),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _buildExpensePieSections(
                        expensesByCategory,
                        totalExpensesAbs,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: expensesByCategory.entries.map((e) {
              final pct =
                  totalExpensesAbs == 0 ? 0 : (e.value / totalExpensesAbs * 100);
              return Chip(
                label: Text('${e.key} • ${pct.toStringAsFixed(1)}%'),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Balance per account',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: totalsByAccount.isEmpty
                ? const Center(
                    child: Text('No data yet to show by account.'),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 &&
                                  index < totalsByAccount.keys.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    totalsByAccount.keys.elementAt(index),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      barGroups: _buildAccountBarGroups(totalsByAccount),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildExpensePieSections(
    Map<String, double> data,
    double total,
  ) {
    final colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
    ];

    final entries = data.entries.toList();
    return List.generate(entries.length, (index) {
      final e = entries[index];
      final value = e.value;
      final pct = total == 0 ? 0 : value / total * 100;
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: value,
        radius: 70,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<BarChartGroupData> _buildAccountBarGroups(
    Map<String, double> totalsByAccount,
  ) {
    final entries = totalsByAccount.entries.toList();
    return List.generate(entries.length, (index) {
      final e = entries[index];
      final isPositive = e.value >= 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: isPositive ? Colors.green : Colors.red,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Dark theme'),
          value: widget.isDarkTheme,
          onChanged: widget.onThemeChanged,
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Manage accounts'),
          subtitle: Text('${_accounts.length} accounts'),
          onTap: _addAccount,
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Clear all transactions'),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear all?'),
                content: const Text(
                  'This will remove all saved transactions on this device.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              setState(() => _transactions.clear());
              await _saveTransactions();
            }
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}

class _TransactionForm extends StatefulWidget {
  final List<String> accounts;
  final ValueChanged<WalletTransaction> onSubmit;

  const _TransactionForm({
    required this.accounts,
    required this.onSubmit,
  });

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _category = 'General';
  String? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.accounts.isNotEmpty ? widget.accounts.first : 'Main';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null) return;

    final tx = WalletTransaction(
      title: _titleCtrl.text.trim(),
      amount: amount,
      category: _category,
      account: _selectedAccount ?? 'Main',
      date: DateTime.now(),
    );

    widget.onSubmit(tx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Add transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Salary, Groceries, Transport…',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'e.g. 1200.50 (negative for expense)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter amount';
                  }
                  final parsed = double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null) {
                    return 'Enter valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Food', child: Text('Food')),
                  DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                  DropdownMenuItem(value: 'Bills', child: Text('Bills')),
                  DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedAccount,
                decoration: const InputDecoration(labelText: 'Account'),
                items: widget.accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a,
                        child: Text(a),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedAccount = value);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}