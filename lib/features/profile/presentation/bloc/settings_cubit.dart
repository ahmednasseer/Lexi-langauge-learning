import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final bool darkMode;
  final bool notificationsEnabled;
  final String learningLanguage;
  final int dailyGoal;

  const SettingsLoaded({
    required this.darkMode,
    required this.notificationsEnabled,
    required this.learningLanguage,
    required this.dailyGoal,
  });

  @override
  List<Object?> get props => [darkMode, notificationsEnabled, learningLanguage, dailyGoal];

  SettingsLoaded copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    String? learningLanguage,
    int? dailyGoal,
  }) {
    return SettingsLoaded(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(SettingsInitial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      emit(SettingsLoaded(
        darkMode: _prefs.getBool('dark_mode') ?? false,
        notificationsEnabled: _prefs.getBool('notifications_enabled') ?? true,
        learningLanguage: _prefs.getString('learning_language') ?? 'German',
        dailyGoal: _prefs.getInt('daily_goal') ?? 50,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> toggleDarkMode() async {
    final current = state is SettingsLoaded ? (state as SettingsLoaded).darkMode : false;
    final newValue = !current;
    await _prefs.setBool('dark_mode', newValue);
    if (state is SettingsLoaded) {
      emit((state as SettingsLoaded).copyWith(darkMode: newValue));
    }
  }

  Future<void> toggleNotifications() async {
    final current = state is SettingsLoaded ? (state as SettingsLoaded).notificationsEnabled : true;
    final newValue = !current;
    await _prefs.setBool('notifications_enabled', newValue);
    if (state is SettingsLoaded) {
      emit((state as SettingsLoaded).copyWith(notificationsEnabled: newValue));
    }
  }

  Future<void> setLearningLanguage(String language) async {
    await _prefs.setString('learning_language', language);
    if (state is SettingsLoaded) {
      emit((state as SettingsLoaded).copyWith(learningLanguage: language));
    }
  }

  Future<void> setDailyGoal(int goal) async {
    await _prefs.setInt('daily_goal', goal);
    if (state is SettingsLoaded) {
      emit((state as SettingsLoaded).copyWith(dailyGoal: goal));
    }
  }
}
