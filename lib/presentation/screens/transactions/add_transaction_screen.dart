import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/app_entities.dart';
import '../../controllers/app_controllers.dart';
import '../../../core/utils/currency_utils.dart';


class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    required this.controller,
  });

  final TransactionsController controller;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  TransactionTypeEntity _selectedType = TransactionTypeEntity.expense;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  IconData _selectedCategoryIcon = Icons.category_rounded;

  bool _isRecurring = false;
  RecurringIntervalEntity? _recurringInterval;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: appColors.surface,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: appColors.surface,
              headerForegroundColor: appColors.textPrimary,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return appColors.black;
                }
                return appColors.textPrimary;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return appColors.green;
                }
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStatePropertyAll(appColors.green),
              todayBorder: BorderSide(color: appColors.green),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: appColors.textSecondary,
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: appColors.green,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        // Keep the chosen day, but reset time to now when saving.
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveTransaction() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Merge picked date (year/month/day) with current time (hour/minute/second).
    final now = DateTime.now();
    final dateWithCurrentTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    final transaction = TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: amount,
      type: _selectedType,
      category: _categoryController.text.trim().isEmpty
          ? 'General'
          : _categoryController.text.trim(),
      date: dateWithCurrentTime,
      note: _noteController.text.trim(),
      isRecurring: _isRecurring && _recurringInterval != null,
      recurringInterval: _isRecurring ? _recurringInterval : null,
    );

    await widget.controller.addTransaction(transaction);

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  Future<void> _showCategoryIconPicker() async {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    final selected = await showModalBottomSheet<IconData>(
      context: context,
      showDragHandle: true,
      backgroundColor: appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final icons = _CategoryIconHelper.predefinedIcons;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose category icon',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: GridView.builder(
                    itemCount: icons.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final icon = icons[index];
                      final isSelected = icon == _selectedCategoryIcon;

                      return InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          Navigator.of(context).pop(icon);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? appColors.green.withValues(alpha: 0.18)
                                : appColors.surfaceAlt,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: appColors.green, width: 2)
                                : null,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? appColors.green
                                : appColors.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedCategoryIcon = selected;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Transaction'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _SectionCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'Salary, food, rent...',
                            prefixIcon: Icon(Icons.edit_outlined),
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
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.currency_exchange_rounded),
                            prefixText: CurrencyUtils.symbol,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter amount';
                            }
                            final parsed = double.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<TransactionTypeEntity>(
                          initialValue: _selectedType,
                          dropdownColor: appColors.surface,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: appColors.textSecondary,
                            size: 20,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            prefixIcon: Icon(Icons.swap_vert_rounded),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: TransactionTypeEntity.income,
                              child: Text('Income'),
                            ),
                            DropdownMenuItem(
                              value: TransactionTypeEntity.expense,
                              child: Text('Expense'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _categoryController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            hintText: 'Work, food, shopping...',
                            helperText:
                                'Tap the left icon to choose a category icon',
                            prefixIcon: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: _showCategoryIconPicker,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  _selectedCategoryIcon,
                                ),
                              ),
                            ),
                            suffixIcon: IconButton(
                              tooltip: 'Choose icon',
                              onPressed: _showCategoryIconPicker,
                              icon: const Icon(Icons.palette_outlined),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.trim().isEmpty) return;
                            setState(() {
                              _selectedCategoryIcon =
                                  _CategoryIconHelper.iconForCategory(
                                      value.trim());
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _noteController,
                          textInputAction: TextInputAction.done,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Note',
                            hintText: 'Optional note',
                            prefixIcon: Icon(Icons.notes_rounded),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: appColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: appColors.textPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(_selectedDate),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(
                            Icons.event_rounded,
                            size: 18,
                          ),
                          label: const Text('Choose'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Repeat'),
                          subtitle: const Text(
                              'Create this transaction automatically'),
                          value: _isRecurring,
                          onChanged: (value) {
                            setState(() {
                              _isRecurring = value;
                              if (!value) {
                                _recurringInterval = null;
                              } else {
                                _recurringInterval ??=
                                    RecurringIntervalEntity.monthly;
                              }
                            });
                          },
                        ),
                        if (_isRecurring) ...[
                          const SizedBox(height: 8),
                          DropdownButtonFormField<RecurringIntervalEntity>(
                            initialValue: _recurringInterval ??
                                RecurringIntervalEntity.monthly,
                            decoration: const InputDecoration(
                              labelText: 'Repeat every',
                              prefixIcon: Icon(Icons.repeat_rounded),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: RecurringIntervalEntity.daily,
                                child: Text('Daily'),
                              ),
                              DropdownMenuItem(
                                value: RecurringIntervalEntity.weekly,
                                child: Text('Weekly'),
                              ),
                              DropdownMenuItem(
                                value: RecurringIntervalEntity.monthly,
                                child: Text('Monthly'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _recurringInterval = value;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveTransaction,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(
                              Icons.check_rounded,
                              size: 18,
                            ),
                      label: Text(_isSaving ? 'Saving...' : 'Save Transaction'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryIconHelper {
  static const List<IconData> predefinedIcons = [
    Icons.restaurant_rounded,
    Icons.local_cafe_rounded,
    Icons.shopping_bag_rounded,
    Icons.directions_car_rounded,
    Icons.train_rounded,
    Icons.pedal_bike_rounded,
    Icons.flight_rounded,
    Icons.luggage_rounded,
    Icons.hotel_rounded,
    Icons.home_rounded,
    Icons.receipt_long_rounded,
    Icons.smartphone_rounded,
    Icons.local_hospital_rounded,
    Icons.medication_rounded,
    Icons.fitness_center_rounded,
    Icons.pets_rounded,
    Icons.child_friendly_rounded,
    Icons.school_rounded,
    Icons.movie_rounded,
    Icons.music_note_rounded,
    Icons.sports_esports_rounded,
    Icons.celebration_rounded,
    Icons.card_giftcard_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.work_rounded,
    Icons.credit_card_rounded,
    Icons.savings_rounded,
    Icons.trending_up_rounded,
    Icons.account_balance_rounded,
    Icons.volunteer_activism_rounded,
    Icons.build_rounded,
    Icons.inventory_2_rounded,
    Icons.subscriptions_rounded,
    Icons.shield_rounded,
    Icons.category_rounded,
  ];

  static IconData iconForCategory(String category) {
    final c = category.trim().toLowerCase();

    if (c.contains('food') ||
        c.contains('restaurant') ||
        c.contains('meal') ||
        c.contains('lunch') ||
        c.contains('dinner') ||
        c.contains('breakfast') ||
        c.contains('grocery') ||
        c.contains('groceries') ||
        c.contains('supermarket')) {
      return Icons.restaurant_rounded;
    }

    if (c.contains('coffee') ||
        c.contains('cafe') ||
        c.contains('tea') ||
        c.contains('drink')) {
      return Icons.local_cafe_rounded;
    }

    if (c.contains('car') ||
        c.contains('transport') ||
        c.contains('taxi') ||
        c.contains('uber') ||
        c.contains('bus') ||
        c.contains('fuel') ||
        c.contains('gas') ||
        c.contains('petrol')) {
      return Icons.directions_car_rounded;
    }

    if (c.contains('train') || c.contains('metro') || c.contains('subway')) {
      return Icons.train_rounded;
    }

    if (c.contains('bike') || c.contains('bicycle')) {
      return Icons.pedal_bike_rounded;
    }

    if (c.contains('flight') || c.contains('air') || c.contains('plane')) {
      return Icons.flight_rounded;
    }

    if (c.contains('travel') ||
        c.contains('trip') ||
        c.contains('vacation') ||
        c.contains('holiday')) {
      return Icons.luggage_rounded;
    }

    if (c.contains('hotel') || c.contains('stay')) {
      return Icons.hotel_rounded;
    }

    if (c.contains('shopping') ||
        c.contains('shop') ||
        c.contains('clothes') ||
        c.contains('clothing') ||
        c.contains('market') ||
        c.contains('mall')) {
      return Icons.shopping_bag_rounded;
    }

    if (c.contains('beauty') ||
        c.contains('cosmetic') ||
        c.contains('makeup') ||
        c.contains('skincare') ||
        c.contains('salon') ||
        c.contains('barber')) {
      return Icons.face_retouching_natural_rounded;
    }

    if (c.contains('home') ||
        c.contains('rent') ||
        c.contains('house') ||
        c.contains('apartment')) {
      return Icons.home_rounded;
    }

    if (c.contains('bill') ||
        c.contains('electric') ||
        c.contains('electricity') ||
        c.contains('water') ||
        c.contains('internet') ||
        c.contains('wifi') ||
        c.contains('utility') ||
        c.contains('utilities')) {
      return Icons.receipt_long_rounded;
    }

    if (c.contains('phone') ||
        c.contains('mobile') ||
        c.contains('call') ||
        c.contains('sim')) {
      return Icons.smartphone_rounded;
    }

    if (c.contains('health') ||
        c.contains('doctor') ||
        c.contains('hospital') ||
        c.contains('medicine') ||
        c.contains('medical') ||
        c.contains('clinic')) {
      return Icons.local_hospital_rounded;
    }

    if (c.contains('pharmacy') || c.contains('drug')) {
      return Icons.medication_rounded;
    }

    if (c.contains('gym') ||
        c.contains('fitness') ||
        c.contains('workout') ||
        c.contains('sport') ||
        c.contains('sports')) {
      return Icons.fitness_center_rounded;
    }

    if (c.contains('pet') ||
        c.contains('dog') ||
        c.contains('cat') ||
        c.contains('animal') ||
        c.contains('vet')) {
      return Icons.pets_rounded;
    }

    if (c.contains('baby') || c.contains('kids') || c.contains('child')) {
      return Icons.child_friendly_rounded;
    }

    if (c.contains('education') ||
        c.contains('school') ||
        c.contains('book') ||
        c.contains('course') ||
        c.contains('university') ||
        c.contains('study')) {
      return Icons.school_rounded;
    }

    if (c.contains('movie') || c.contains('cinema') || c.contains('film')) {
      return Icons.movie_rounded;
    }

    if (c.contains('music') || c.contains('song') || c.contains('spotify')) {
      return Icons.music_note_rounded;
    }

    if (c.contains('game') || c.contains('gaming')) {
      return Icons.sports_esports_rounded;
    }

    if (c.contains('entertainment') || c.contains('fun')) {
      return Icons.celebration_rounded;
    }

    if (c.contains('gift') || c.contains('bonus') || c.contains('present')) {
      return Icons.card_giftcard_rounded;
    }

    if (c.contains('salary') ||
        c.contains('income') ||
        c.contains('job') ||
        c.contains('work') ||
        c.contains('wage')) {
      return Icons.account_balance_wallet_rounded;
    }

    if (c.contains('freelance') ||
        c.contains('business') ||
        c.contains('project')) {
      return Icons.work_rounded;
    }

    if (c.contains('bank') ||
        c.contains('transfer') ||
        c.contains('card') ||
        c.contains('payment')) {
      return Icons.credit_card_rounded;
    }

    if (c.contains('saving') ||
        c.contains('savings') ||
        c.contains('deposit')) {
      return Icons.savings_rounded;
    }

    if (c.contains('investment') ||
        c.contains('stock') ||
        c.contains('crypto')) {
      return Icons.trending_up_rounded;
    }

    if (c.contains('tax')) {
      return Icons.account_balance_rounded;
    }

    if (c.contains('charity') || c.contains('donation')) {
      return Icons.volunteer_activism_rounded;
    }

    if (c.contains('repair') ||
        c.contains('maintenance') ||
        c.contains('tool')) {
      return Icons.build_rounded;
    }

    if (c.contains('office') ||
        c.contains('stationery') ||
        c.contains('supplies')) {
      return Icons.inventory_2_rounded;
    }

    if (c.contains('subscription') ||
        c.contains('netflix') ||
        c.contains('youtube')) {
      return Icons.subscriptions_rounded;
    }

    if (c.contains('security') || c.contains('insurance')) {
      return Icons.shield_rounded;
    }

    return Icons.category_rounded;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}
