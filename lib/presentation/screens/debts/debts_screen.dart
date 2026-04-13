import 'package:flutter/material.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final debts = const [
      _DebtItem(
        title: 'Credit Card',
        lender: 'Visa Bank',
        amountLeft: 1850,
        monthlyPayment: 250,
        progress: 0.62,
        color: Colors.red,
        icon: Icons.credit_card_rounded,
      ),
      _DebtItem(
        title: 'Car Loan',
        lender: 'Auto Finance',
        amountLeft: 7200,
        monthlyPayment: 480,
        progress: 0.35,
        color: Colors.blue,
        icon: Icons.directions_car_rounded,
      ),
      _DebtItem(
        title: 'Personal Loan',
        lender: 'City Bank',
        amountLeft: 3200,
        monthlyPayment: 300,
        progress: 0.54,
        color: Colors.orange,
        icon: Icons.account_balance_rounded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debts'),
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
                  'Total Debt',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$12,250.00',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monthly payments: \$1,030.00',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Active Debts',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...debts.map((debt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: debt.color.withValues(alpha: 0.12),
                            child: Icon(
                              debt.icon,
                              color: debt.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  debt.title,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  debt.lender,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${debt.amountLeft.toStringAsFixed(0)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: debt.progress,
                          minHeight: 10,
                          backgroundColor: debt.color.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(debt.color),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(debt.progress * 100).toStringAsFixed(0)}% paid',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            'Monthly: \$${debt.monthlyPayment.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DebtItem {
  final String title;
  final String lender;
  final double amountLeft;
  final double monthlyPayment;
  final double progress;
  final Color color;
  final IconData icon;

  const _DebtItem({
    required this.title,
    required this.lender,
    required this.amountLeft,
    required this.monthlyPayment,
    required this.progress,
    required this.color,
    required this.icon,
  });
}