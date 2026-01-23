import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../transactions/domain/transaction_model.dart';
import '../../transactions/presentation/add_transaction_modal.dart';
import '../../transactions/presentation/transactions_controller.dart';
import '../../../core/presentation/widgets/glass_container.dart';
import '../../../core/presentation/widgets/liquid_background.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/transaction_summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openAddTransactionOverlay(
    BuildContext context, {
    TransactionModel? transaction,
    String? category,
    TransactionType? type,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTransactionModal(
        transaction: transaction,
        initialCategory: category,
        initialType: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsValue = ref.watch(transactionsControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Expense Tracker'),
        backgroundColor: Colors.transparent,
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: transactionsValue.when(
            data: (transactions) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: TransactionSummaryCard(transactions: transactions),
                  ),
                  SliverToBoxAdapter(child: _buildQuickCategories(context)),
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      context,
                      title: 'Recent Transactions',
                    ),
                  ),
                  if (transactions.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: GlassContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          child: const Text(
                            'No transactions yet.\nAdd one to start tracking!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final transaction = transactions[index];
                        final isExpense =
                            transaction.type == TransactionType.expense;

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Slidable(
                            key: ValueKey(transaction.id),
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) =>
                                      _openAddTransactionOverlay(
                                        context,
                                        transaction: transaction,
                                      ),
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    ref
                                        .read(
                                          transactionsControllerProvider
                                              .notifier,
                                        )
                                        .deleteTransaction(transaction.id);
                                  },
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () => _openAddTransactionOverlay(
                                context,
                                transaction: transaction,
                              ),
                              child: GlassContainer(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                borderRadius: 16,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isExpense
                                            ? Colors.redAccent.withValues(
                                                alpha: 0.2,
                                              )
                                            : Colors.greenAccent.withValues(
                                                alpha: 0.2,
                                              ),
                                        border: Border.all(
                                          color: isExpense
                                              ? Colors.redAccent.withValues(
                                                  alpha: 0.5,
                                                )
                                              : Colors.greenAccent.withValues(
                                                  alpha: 0.5,
                                                ),
                                        ),
                                      ),
                                      child: Icon(
                                        isExpense
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        color: isExpense
                                            ? Colors.redAccent
                                            : Colors.greenAccent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat.yMMMd().format(
                                              transaction.date,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.white54,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${transaction.amount.toStringAsFixed(2)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: isExpense
                                                    ? Colors.redAccent
                                                    : Colors.greenAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          transaction.category,
                                          style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: transactions.length),
                    ),
                  // Add bottom padding for FAB
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransactionOverlay(context),
        backgroundColor: Colors.transparent, // Hack to allow gradient
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.accentGradient,
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildQuickCategories(BuildContext context) {
    final categories = [
      {
        'name': 'Food',
        'icon': Icons.restaurant_rounded,
        'color': Colors.orangeAccent,
      },
      {
        'name': 'Transport',
        'icon': Icons.directions_car_rounded,
        'color': Colors.blueAccent,
      },
      {
        'name': 'Shopping',
        'icon': Icons.shopping_bag_rounded,
        'color': Colors.pinkAccent,
      },
      {
        'name': 'Health',
        'icon': Icons.medical_services_rounded,
        'color': Colors.greenAccent,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, title: 'Quick Categories'),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _openAddTransactionOverlay(
                    context,
                    category: cat['name'] as String,
                    type: TransactionType.expense,
                  ),
                  child: Column(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        child: Icon(
                          cat['icon'] as IconData,
                          color: cat['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (title == 'Recent Transactions')
            TextButton(
              onPressed: () {
                // Future: Navigate to all transactions
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
