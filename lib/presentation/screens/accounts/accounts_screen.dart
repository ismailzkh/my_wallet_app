import 'package:flutter/material.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final accounts = const [
      _AccountItem(
        title: 'Main Wallet',
        subtitle: 'Daily spending account',
        balance: 2450.75,
        icon: Icons.account_balance_wallet_rounded,
        color: Colors.blue,
      ),
      _AccountItem(
        title: 'Savings',
        subtitle: 'Emergency fund',
        balance: 10200.00,
        icon: Icons.savings_rounded,
        color: Colors.green,
      ),
      _AccountItem(
        title: 'Cash',
        subtitle: 'Available cash',
        balance: 680.50,
        icon: Icons.payments_rounded,
        color: Colors.orange,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Assets',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$13,331.25',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'My Accounts',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...accounts.map(
            (account) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: account.color.withValues(alpha: 0.12),
                    child: Icon(
                      account.icon,
                      color: account.color,
                    ),
                  ),
                  title: Text(account.title),
                  subtitle: Text(account.subtitle),
                  trailing: Text(
                    '\$${account.balance.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountItem {
  final String title;
  final String subtitle;
  final double balance;
  final IconData icon;
  final Color color;

  const _AccountItem({
    required this.title,
    required this.subtitle,
    required this.balance,
    required this.icon,
    required this.color,
  });
}