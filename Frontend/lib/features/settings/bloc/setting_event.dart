part of 'setting_bloc.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingEvent {}

class ChangeBoardThemeEvent extends SettingEvent {
  final String theme;
  const ChangeBoardThemeEvent(this.theme);
  @override
  List<Object?> get props => [theme];
}

class ChangePieceStyleEvent extends SettingEvent {
  final String style;
  const ChangePieceStyleEvent(this.style);
  @override
  List<Object?> get props => [style];
}

class ChangeClockStyleEvent extends SettingEvent {
  final String style;
  const ChangeClockStyleEvent(this.style);
  @override
  List<Object?> get props => [style];
}

enum ToggleType { highlightMove, hintMove, sound, backgroundMusic, darkMode }

class ToggleSettingEvent extends SettingEvent {
  final ToggleType type;
  const ToggleSettingEvent(this.type);
  @override
  List<Object?> get props => [type];
}
