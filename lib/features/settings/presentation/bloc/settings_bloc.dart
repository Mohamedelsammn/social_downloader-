import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_event.dart';
part 'settings_state.dart';

const _kQuality = 'settings_quality';
const _kAutoSave = 'settings_auto_save';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;

  SettingsBloc(this._prefs) : super(const SettingsState()) {
    on<SettingsLoaded>(_onLoaded);
    on<SettingsQualityChanged>(_onQualityChanged);
    on<SettingsAutoSaveToggled>(_onAutoSaveToggled);
    add(const SettingsLoaded());
  }

  void _onLoaded(SettingsLoaded _, Emitter<SettingsState> emit) {
    emit(SettingsState(
      quality: _prefs.getString(_kQuality) ?? '720p',
      autoSave: _prefs.getBool(_kAutoSave) ?? true,
    ));
  }

  void _onQualityChanged(
      SettingsQualityChanged event, Emitter<SettingsState> emit) {
    _prefs.setString(_kQuality, event.quality);
    emit(state.copyWith(quality: event.quality));
  }

  void _onAutoSaveToggled(
      SettingsAutoSaveToggled _, Emitter<SettingsState> emit) {
    final next = !state.autoSave;
    _prefs.setBool(_kAutoSave, next);
    emit(state.copyWith(autoSave: next));
  }
}
