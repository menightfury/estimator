part of 'create_estimate_cubit.dart';

class CreateEstimateState extends Equatable {
  const CreateEstimateState({this.items = const [], this.selectedItem});

  final List<EstimateItem> items;
  final EstimateItem? selectedItem;

  @override
  List<Object?> get props => [items, selectedItem];

  CreateEstimateState copyWith({List<EstimateItem>? items, EstimateItem? selectedItem}) {
    return CreateEstimateState(items: items ?? this.items, selectedItem: selectedItem ?? this.selectedItem);
  }
}
