import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/glass_container.dart';
import '../../../transactions/domain/transaction_model.dart';

class TransactionSummaryCard extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionSummaryCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Filter for current month using efficient checking
    // Note: TransactionModel date is DateTime
    final currentMonthTransactions = transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();

    double income = 0;
    double expense = 0;

    for (var transaction in currentMonthTransactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    final totalBalance = income - expense;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          children: [
            Text(
              'Total Balance (This Month)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${totalBalance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  context,
                  label: 'Income',
                  amount: income,
                  icon: Icons.arrow_upward,
                  color: Colors.greenAccent,
                ),
                Container(height: 48, width: 1, color: Colors.white24),
                _buildSummaryItem(
                  context,
                  label: 'Expense',
                  amount: expense,
                  icon: Icons.arrow_downward,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
