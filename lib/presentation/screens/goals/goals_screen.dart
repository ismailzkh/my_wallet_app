import 'package:flutter/material.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final goals = const [
      _GoalItem(
        title: 'Emergency Fund',
        targetAmount: 5000,
        savedAmount: 3200,
        color: Colors.green,
        icon: Icons.health_and_safety_rounded,
      ),
      _GoalItem(
        title: 'New Laptop',
        targetAmount: 1800,
        savedAmount: 950,
        color: Colors.blue,
        icon: Icons.laptop_mac_rounded,
      ),
      _GoalItem(
        title: 'Vacation',
        targetAmount: 2500,
        savedAmount: 1100,
        color: Colors.orange,
        icon: Icons.flight_takeoff_rounded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
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
                  'Savings Goals',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$5,250 saved',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Across 3 active goals',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Active Goals',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...goals.map((goal) {
            final progress =
                (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0);

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
                            backgroundColor: goal.color.withValues(alpha: 0.12),
                            child: Icon(
                              goal.icon,
                              color: goal.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              goal.title,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '\$${goal.savedAmount.toStringAsFixed(0)}',
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
                          value: progress,
                          minHeight: 10,
                          backgroundColor: goal.color.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            goal.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% completed',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            'Target: \$${goal.targetAmount.toStringAsFixed(0)}',
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

class _GoalItem {
  final String title;
  final double targetAmount;
  final double savedAmount;
  final Color color;
  final IconData icon;

  const _GoalItem({
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.color,
    required this.icon,
  });
}