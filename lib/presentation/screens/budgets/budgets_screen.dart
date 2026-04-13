import 'package:flutter/material.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final budgets = const [
      _BudgetItem(
        title: 'Food',
        spent: 1240,
        limit: 1600,
        color: Colors.orange,
        icon: Icons.restaurant_rounded,
      ),
      _BudgetItem(
        title: 'Transport',
        spent: 560,
        limit: 900,
        color: Colors.blue,
        icon: Icons.directions_car_rounded,
      ),
      _BudgetItem(
        title: 'Shopping',
        spent: 890,
        limit: 1000,
        color: Colors.purple,
        icon: Icons.shopping_bag_rounded,
      ),
      _BudgetItem(
        title: 'Bills',
        spent: 1320,
        limit: 1400,
        color: Colors.red,
        icon: Icons.receipt_long_rounded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
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
                  'Monthly Budget',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$4,010 / \$4,900',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 0.82,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Category Budgets',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...budgets.map((budget) {
            final progress = (budget.spent / budget.limit).clamp(0.0, 1.0);
            final isOverLimit = budget.spent > budget.limit;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                budget.color.withValues(alpha: 0.12),
                            child: Icon(
                              budget.icon,
                              color: budget.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              budget.title,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '\$${budget.spent.toStringAsFixed(0)} / \$${budget.limit.toStringAsFixed(0)}',
                            style:
                                theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor:
                              budget.color.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverLimit ? Colors.red : budget.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isOverLimit
                            ? 'Budget exceeded'
                            : '\$${(budget.limit - budget.spent).toStringAsFixed(0)} left',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverLimit ? Colors.red : null,
                        ),
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

class _BudgetItem {
  final String title;
  final double spent;
  final double limit;
  final Color color;
  final IconData icon;

  const _BudgetItem({
    required this.title,
    required this.spent,
    required this.limit,
    required this.color,
    required this.icon,
  });
}