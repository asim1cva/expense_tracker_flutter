import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_model.dart';

part 'transactions_controller.g.dart';

@riverpod
class TransactionsController extends _$TransactionsController {
  @override
  FutureOr<List<TransactionModel>> build() {
    return ref.watch(transactionRepositoryProvider).fetchTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.addTransaction(transaction);
      return repository.fetchTransactions();
    });
  }

  Future<void> editTransaction(TransactionModel transaction) async {
    final repository = ref.read(transactionRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.updateTransaction(transaction);
      return repository.fetchTransactions();
    });
  }

  Future<void> deleteTransaction(String id) async {
    final repository = ref.read(transactionRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteTransaction(id);
      return repository.fetchTransactions();
    });
  }
}
