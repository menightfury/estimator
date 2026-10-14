import 'package:estimator/common/utils/debouncer.dart';
import 'package:estimator/common_libs.dart';
import 'package:estimator/database/repository.dart';
import 'package:estimator/model/item_model.dart';

part 'edit_item_state.dart';

class EditItemCubit extends Cubit<EditItemState> {
  EditItemCubit({
    required this.repository,
    EstimatorItem? initialItem,
  }) : _debouncer = Debouncer(const Duration(milliseconds: 350)),
       super(
         initialItem != null
             ? EditItemState(
                 status: EditItemStatus.loaded,
                 id: initialItem.id,
                 name: initialItem.name,
                 description: initialItem.description,
                 unit: initialItem.unit,
                 type: initialItem.type,
               )
             : const EditItemState(),
       );

  final EstimatorRepository repository;
  final Debouncer _debouncer;

  // ─── Name field ──────────────────────────────────────────────────────────

  /// Called every time the user types in the name field.
  /// Debounces database searches and validates uniqueness against suggestions.
  Future<void> onNameChanged(String value) async {
    // Clear previous error eagerly; it will be re-set after search.
    emit(
      state.copyWith(
        status: EditItemStatus.editing,
        name: value,
        nameError: () => null,
        isLoadingSuggestions: true,
        suggestions: [],
      ),
    );

    if (value.trim().isEmpty) {
      emit(state.copyWith(isLoadingSuggestions: false, suggestions: []));
      return;
    }

    await _debouncer.wait();
    if (isClosed) return;

    try {
      final results = await repository.searchItems(value.trim());
      if (isClosed) return;

      // Check if the typed name already belongs to a *different* item.
      final exactMatch = results.firstWhereOrNull(
        (item) => item.name.toLowerCase() == value.trim().toLowerCase(),
      );

      String? nameError;
      if (exactMatch != null && exactMatch.id != state.id) {
        nameError = 'Name already exists';
      }

      emit(
        state.copyWith(
          suggestions: results,
          isLoadingSuggestions: false,
          nameError: () => nameError,
        ),
      );
    } on Exception catch (e) {
      $logger.e(e);
      emit(state.copyWith(isLoadingSuggestions: false, suggestions: []));
    }
  }

  /// Called when the user picks one of the suggestion items.
  /// Loads the selected item into edit mode.
  void onSuggestionSelected(EstimatorItem item) {
    emit(
      EditItemState(
        status: EditItemStatus.loaded,
        id: item.id,
        name: item.name,
        description: item.description,
        unit: item.unit,
        type: item.type,
        suggestions: const [],
        isLoadingSuggestions: false,
      ),
    );
  }

  // ─── Field updates ───────────────────────────────────────────────────────

  void onDescriptionChanged(String value) {
    emit(state.copyWith(status: EditItemStatus.editing, description: value));
  }

  void onUnitChanged(String? value) {
    emit(
      state.copyWith(
        status: EditItemStatus.editing,
        unit: () => value,
      ),
    );
  }

  void onTypeChanged(EstimatorItemType? value) {
    emit(
      state.copyWith(
        status: EditItemStatus.editing,
        type: () => value,
      ),
    );
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> save() async {
    // Final validation
    if (state.name.trim().isEmpty) {
      emit(state.copyWith(nameError: () => 'Name is required'));
      return;
    }
    if (state.nameError != null) return;
    if (state.unit == null) return;

    emit(state.copyWith(status: EditItemStatus.saving));

    try {
      final itemId = state.id ?? $uuid.v4();
      final item = ItemInDb(
        id: itemId,
        name: state.name.trim(),
        description: state.description.trim(),
        unit: state.unit!,
        typeString: state.type?.name,
      );

      await repository.saveItem(item, isNew: state.isNew);

      emit(
        state.copyWith(
          status: EditItemStatus.saved,
          id: () => itemId,
        ),
      );
    } on Exception catch (e) {
      $logger.e(e);
      emit(state.copyWith(status: EditItemStatus.errorSaving));
    }
  }

  /// Resets the form to a blank "new item" state.
  void reset() {
    emit(const EditItemState());
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
