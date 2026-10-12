import 'package:estimator/common_libs.dart';
import 'package:estimator/model/estimate_model.dart';

part 'create_estimate_state.dart';

class CreateEstimateCubit extends Cubit<CreateEstimateState> {
  CreateEstimateCubit() : super(CreateEstimateState());

  void addItem(EstimateItem item) {
    final List<EstimateItem> items = List.from(state.items);
    emit(state.copyWith(items: items..add(item)));
  }

  void removeItem(EstimateItem item) {
    final List<EstimateItem> items = List.from(state.items);
    emit(state.copyWith(items: items..remove(item)));
  }

  void updateSelectedItem(EstimateItem item) {
    emit(state.copyWith(selectedItem: item));
  }
}
