import 'dart:async';

import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/item_model.dart';

part 'items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  ItemsCubit({required this.repository}) : super(ItemsInitialState());

  final EstimatorRepository repository;
  // int _loadRequestId = 0;

  StreamSubscription<List<EstimatorItem>>? _subscription;

  // Future<void> loadItems() async {
  //   final requestId = ++_loadRequestId;
  //   emit(ItemsLoadingState());

  //   try {
  //     final items = await repository.getItems();
  //     if (isClosed || requestId != _loadRequestId) return;
  //     emit(ItemsLoadedState(items));
  //   } on Exception catch (error, stackTrace) {
  //     $logger.e('Failed to load items', error: error, stackTrace: stackTrace);
  //     if (isClosed || requestId != _loadRequestId) return;
  //     emit(ItemsErrorState(error.toString()));
  //   }
  // }

  // Listen to changes in the items table and reload items when a change occurs
  Future<void> fetchItems() async {
    emit(ItemsLoadingState());
    _subscription ??= repository.fetchItems().listen(
      (items) {
        if (isClosed) return;
        emit(ItemsLoadedState(items));
      },
      onError: (error, stackTrace) {
        $logger.e('Failed to fetch items', error: error, stackTrace: stackTrace);
        if (isClosed) return;
        emit(ItemsErrorState(error.toString()));
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
