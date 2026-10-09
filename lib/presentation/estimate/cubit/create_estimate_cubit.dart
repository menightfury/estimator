import 'package:estimator/common_libs.dart';
import 'package:estimator/model/estimate_model.dart';

part 'create_estimate_state.dart';

class CreateEstimateCubit extends Cubit<CreateEstimateState> {
  CreateEstimateCubit() : super(CreateEstimateState());

  void updateSelectedItem(EstimateItem item) {
    emit(state.copyWith(selectedItem: item));
  }
}
