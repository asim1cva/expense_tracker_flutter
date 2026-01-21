import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/transaction_model.dart';

part 'transaction_repository.g.dart';

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository();
}

class TransactionRepository {
  final Box _box = Hive.box('transactions');

  Future<List<TransactionModel>> fetchTransactions() async {
    final transactions = _box.values
        .map((e) {
          // Assuming we store as Map because we are avoiding TypeAdapters gen issues for now
          // or we can just cast if we trust the data.
          // Better to store as Json Map.
          if (e is Map) {
            return TransactionModel.fromJson(Map<String, dynamic>.from(e));
          }
          return null;
        })
        .whereType<TransactionModel>()
        .toList();

    // Sort by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction.toJson());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }
}
