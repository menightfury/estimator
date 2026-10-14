part of 'edit_item_cubit.dart';

enum EditItemStatus { initial, loading, loaded, editing, saving, saved, errorSaving }

class EditItemState extends Equatable {
  const EditItemState({
    this.status = EditItemStatus.initial,
    this.id,
    this.name = '',
    this.description = '',
    this.unit,
    this.type,
    this.suggestions = const [],
    this.isLoadingSuggestions = false,
    this.nameError,
  });

  final EditItemStatus status;

  /// Null when creating a new item; set when editing an existing one.
  final String? id;

  final String name;
  final String description;
  final String? unit;
  final EstimatorItemType? type;

  /// Live suggestions while the user types in the name field.
  final List<EstimatorItem> suggestions;
  final bool isLoadingSuggestions;

  final String? nameError;

  bool get isNew => id == null;

  bool get isFormValid => name.trim().isNotEmpty && unit != null && nameError == null;

  EditItemState copyWith({
    EditItemStatus? status,
    String? Function()? id,
    String? name,
    String? description,
    String? Function()? unit,
    EstimatorItemType? Function()? type,
    List<EstimatorItem>? suggestions,
    bool? isLoadingSuggestions,
    String? Function()? nameError,
  }) {
    return EditItemState(
      status: status ?? this.status,
      id: id != null ? id() : this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit != null ? unit() : this.unit,
      type: type != null ? type() : this.type,
      suggestions: suggestions ?? this.suggestions,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      nameError: nameError != null ? nameError() : this.nameError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    id,
    name,
    description,
    unit,
    type,
    suggestions,
    isLoadingSuggestions,
    nameError,
  ];
}

extension EditItemStateX on EditItemState {
  bool get isSaving => status == EditItemStatus.saving;
  bool get isSaved => status == EditItemStatus.saved;
  bool get isErrorSaving => status == EditItemStatus.errorSaving;
}
