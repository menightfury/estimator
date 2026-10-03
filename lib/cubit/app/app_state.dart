part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({this.isDarkMode = false});

  final bool isDarkMode;

  AppState copyWith({bool? isDarkMode}) {
    return AppState(isDarkMode: isDarkMode ?? this.isDarkMode);
  }

  @override
  List<Object?> get props => [isDarkMode];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'isDarkMode': isDarkMode};
  }

  factory AppState.fromMap(Map<String, dynamic> map) {
    return AppState(isDarkMode: map['isDarkMode'] as bool);
  }

  @override
  String toString() => 'SettingsState( isDarkMode: $isDarkMode )';
}
