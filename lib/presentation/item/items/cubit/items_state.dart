part of 'items_cubit.dart';

sealed class ItemsState extends Equatable {
  const ItemsState();

  @override
  List<Object?> get props => [];
}

final class ItemsInitialState extends ItemsState {}

final class ItemsLoadingState extends ItemsState {}

final class ItemsLoadedState extends ItemsState {
  const ItemsLoadedState(this.items);

  final List<EstimatorItem> items;

  @override
  List<Object> get props => [items];
}

final class ItemsErrorState extends ItemsState {
  const ItemsErrorState(this.msg);

  final String msg;

  @override
  List<Object> get props => [msg];
}
