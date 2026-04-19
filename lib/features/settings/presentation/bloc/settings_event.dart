part of 'settings_bloc.dart';

abstract class SettingsEvent {
  const SettingsEvent();
}

class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();
}

class SettingsQualityChanged extends SettingsEvent {
  final String quality;
  const SettingsQualityChanged(this.quality);
}

class SettingsAutoSaveToggled extends SettingsEvent {
  const SettingsAutoSaveToggled();
}
