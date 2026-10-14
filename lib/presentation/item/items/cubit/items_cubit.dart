import 'dart:async';

import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/item_model.dart';

part 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit({required this.repository}) : super(ItemsInitial());

  final EstimatorRepository repository;
  int _loadRequestId = 0;

  StreamSubscription<List<EstimatorItem>>? _subscription;

  Future<void> loadItems() async {
    final requestId = ++_loadRequestId;
    emit(ItemsLoading());

    try {
      final items = await repository.getItems();
      if (isClosed || requestId != _loadRequestId) return;
      emit(ItemsLoaded(items));
    } on Exception catch (error, stackTrace) {
      $logger.e('Failed to load items', error: error, stackTrace: stackTrace);
      if (isClosed || requestId != _loadRequestId) return;
      emit(const ItemsLoadFailure());
    }
  }

  // Listen to changes in the items table and reload items when a change occurs
  Future<void> fetchItems() async {
    emit(ItemsLoading());
    _subscription ??= repository.fetchItems().listen(
      (items) {
        if (isClosed) return;
        emit(ItemsLoaded(items));
      },
      onError: (error, stackTrace) {
        $logger.e('Failed to fetch items', error: error, stackTrace: stackTrace);
        if (isClosed) return;
        emit(const ItemsLoadFailure());
      },
      onDone: () {
        _subscription?.cancel();
        _subscription = null;
      },
    );
  }

  @override
  Future<void> close() async {
    _subscription?.cancel();
    _subscription = null;
    await super.close();
  }
}
