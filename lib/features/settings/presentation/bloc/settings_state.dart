part of 'settings_bloc.dart';

class SettingsState {
  final String quality;
  final bool autoSave;

  const SettingsState({
    this.quality = '720p',
    this.autoSave = true,
  });

  SettingsState copyWith({String? quality, bool? autoSave}) => SettingsState(
        quality: quality ?? this.quality,
        autoSave: autoSave ?? this.autoSave,
      );

  @override
  bool operator ==(Object other) =>
      other is SettingsState &&
      other.quality == quality &&
      other.autoSave == autoSave;

  @override
  int get hashCode => Object.hash(quality, autoSave);
}
