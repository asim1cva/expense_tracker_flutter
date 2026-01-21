// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionsController)
final transactionsControllerProvider = TransactionsControllerProvider._();

final class TransactionsControllerProvider
    extends
        $AsyncNotifierProvider<TransactionsController, List<TransactionModel>> {
  TransactionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsControllerHash();

  @$internal
  @override
  TransactionsController create() => TransactionsController();
}

String _$transactionsControllerHash() =>
    r'21e7ef50e935ae4d3e29a58e83266d5dba4c1185';

abstract class _$TransactionsController
    extends $AsyncNotifier<List<TransactionModel>> {
  FutureOr<List<TransactionModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<TransactionModel>>, List<TransactionModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TransactionModel>>,
                List<TransactionModel>
              >,
              AsyncValue<List<TransactionModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
