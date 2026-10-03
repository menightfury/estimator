import 'package:estimator/common_libs.dart';

part 'app_state.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit() : super(AppState());

  void updateThemeMode(bool isDarkMode) async {
    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  @override
  AppState fromJson(Map<String, dynamic> json) {
    return AppState.fromMap(json);
  }

  @override
  Map<String, dynamic> toJson(AppState state) {
    return state.toMap();
  }
}
