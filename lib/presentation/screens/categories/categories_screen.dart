import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final categories = const [
      _CategoryItem(
        name: 'Food',
        icon: Icons.restaurant_rounded,
        color: Colors.orange,
        total: 1240.0,
        transactions: 18,
      ),
      _CategoryItem(
        name: 'Transport',
        icon: Icons.directions_car_rounded,
        color: Colors.blue,
        total: 560.0,
        transactions: 9,
      ),
      _CategoryItem(
        name: 'Shopping',
        icon: Icons.shopping_bag_rounded,
        color: Colors.purple,
        total: 890.0,
        transactions: 11,
      ),
      _CategoryItem(
        name: 'Bills',
        icon: Icons.receipt_long_rounded,
        color: Colors.red,
        total: 1320.0,
        transactions: 6,
      ),
      _CategoryItem(
        name: 'Health',
        icon: Icons.favorite_rounded,
        color: Colors.green,
        total: 430.0,
        transactions: 4,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
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
                  'Top Spending Category',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bills',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$1320.00 this month',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All Categories',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: category.color.withValues(alpha: 0.12),
                    child: Icon(
                      category.icon,
                      color: category.color,
                    ),
                  ),
                  title: Text(category.name),
                  subtitle: Text('${category.transactions} transactions'),
                  trailing: Text(
                    '\$${category.total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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

class _CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final double total;
  final int transactions;

  const _CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.total,
    required this.transactions,
  });
}