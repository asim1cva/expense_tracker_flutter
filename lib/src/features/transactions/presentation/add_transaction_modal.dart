import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

import '../domain/transaction_model.dart';
import 'transactions_controller.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  final TransactionModel? transaction;
  final String? initialCategory;
  final TransactionType? initialType;

  const AddTransactionModal({
    super.key,
    this.transaction,
    this.initialCategory,
    this.initialType,
  });

  @override
  ConsumerState<AddTransactionModal> createState() =>
      _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'Food';

  final Map<String, IconData> _expenseCategories = {
    'Food': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Utilities': Icons.bolt_rounded,
    'Entertainment': Icons.movie_rounded,
    'Health': Icons.medical_services_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Other': Icons.more_horiz_rounded,
  };

  final Map<String, IconData> _incomeCategories = {
    'Salary': Icons.payments_rounded,
    'Freelance': Icons.laptop_mac_rounded,
    'Gift': Icons.card_giftcard_rounded,
    'Investment': Icons.trending_up_rounded,
    'Other': Icons.more_horiz_rounded,
  };

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _titleController.text = t.title;
      _amountController.text = t.amount.toString();
      _selectedDate = t.date;
      _selectedType = t.type;
      _selectedCategory = t.category;
    } else {
      _selectedType = widget.initialType ?? TransactionType.expense;
      _selectedCategory =
          widget.initialCategory ?? _expenseCategories.keys.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitData() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);

    if (title.isEmpty || amount == null || amount <= 0) {
      return;
    }

    if (widget.transaction != null) {
      ref
          .read(transactionsControllerProvider.notifier)
          .editTransaction(
            widget.transaction!.copyWith(
              title: title,
              amount: amount,
              date: _selectedDate,
              category: _selectedCategory,
              type: _selectedType,
            ),
          );
    } else {
      ref
          .read(transactionsControllerProvider.notifier)
          .addTransaction(
            TransactionModel(
              id: const Uuid().v4(),
              title: title,
              amount: amount,
              date: _selectedDate,
              category: _selectedCategory,
              type: _selectedType,
            ),
          );
    }

    context.pop();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.darkScheme.primary,
              onPrimary: Colors.black,
              surface: AppTheme.darkScheme.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = _selectedType == TransactionType.expense
        ? _expenseCategories
        : _incomeCategories;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkScheme.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.transaction != null
                  ? 'Edit Transaction'
                  : 'New Transaction',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Type Selector
            Row(
              children: [
                Expanded(
                  child: _buildTypeToggle(
                    label: 'Expense',
                    icon: Icons.unarchive_rounded,
                    isSelected: _selectedType == TransactionType.expense,
                    color: Colors.redAccent,
                    onTap: () {
                      setState(() {
                        _selectedType = TransactionType.expense;
                        _selectedCategory = _expenseCategories.keys.first;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeToggle(
                    label: 'Income',
                    icon: Icons.archive_rounded,
                    isSelected: _selectedType == TransactionType.income,
                    color: Colors.greenAccent,
                    onTap: () {
                      setState(() {
                        _selectedType = TransactionType.income;
                        _selectedCategory = _incomeCategories.keys.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Amount Field
            _buildAmountField(),
            const SizedBox(height: 20),

            // Title Field
            _buildTextField(
              controller: _titleController,
              label: 'What was this for?',
              icon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 20),

            // Date Picker Row
            _buildDatePicker(),
            const SizedBox(height: 32),

            // Category Selection
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white60,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: currentCategories.length,
                separatorBuilder: (ctx, index) => const SizedBox(width: 16),
                itemBuilder: (ctx, index) {
                  final category = currentCategories.keys.elementAt(index);
                  final icon = currentCategories.values.elementAt(index);
                  final isSelected = _selectedCategory == category;
                  return _buildCategoryItem(category, icon, isSelected);
                },
              ),
            ),

            const SizedBox(height: 40),

            // Action Button
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.5) : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white38, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Text(
            '\$',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _amountController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white38),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _presentDatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Colors.white38),
            const SizedBox(width: 16),
            Text(
              DateFormat('MMMM dd, yyyy').format(_selectedDate),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.darkScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, bool isSelected) {
    final activeColor = _selectedType == TransactionType.expense
        ? Colors.redAccent
        : Colors.greenAccent;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = name),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.5)
                    : Colors.white10,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? activeColor : Colors.white38,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white38,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppTheme.accentGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          widget.transaction != null ? 'SAVE CHANGES' : 'CREATE TRANSACTION',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
