part of 'setting_bloc.dart';

class SettingState extends Equatable {
  final StatusEnum status;
  final String boardTheme;
  final String pieceStyle;
  final String clockStyle;
  final bool highlightMove;
  final bool showHint;
  final bool soundEnabled;
  final bool backgroundMusicEnabled;
  final bool darkMode;

  const SettingState({
    required this.status,
    required this.boardTheme,
    required this.pieceStyle,
    required this.clockStyle,
    required this.highlightMove,
    required this.showHint,
    required this.soundEnabled,
    required this.backgroundMusicEnabled,
    required this.darkMode,
  });

  factory SettingState.initial() => const SettingState(
    status: StatusEnum.initial,
    boardTheme: 'theme_classic',
    pieceStyle: 'style_classic',
    clockStyle: 'clock_digital',
    highlightMove: true,
    showHint: false,
    soundEnabled: true,
    backgroundMusicEnabled: true,
    darkMode: false,
  );

  SettingState copyWith({
    StatusEnum? status,
    String? boardTheme,
    String? pieceStyle,
    String? clockStyle,
    bool? highlightMove,
    bool? showHint,
    bool? soundEnabled,
    bool? backgroundMusicEnabled,
    bool? darkMode,
  }) {
    return SettingState(
      status: status ?? this.status,
      boardTheme: boardTheme ?? this.boardTheme,
      pieceStyle: pieceStyle ?? this.pieceStyle,
      clockStyle: clockStyle ?? this.clockStyle,
      highlightMove: highlightMove ?? this.highlightMove,
      showHint: showHint ?? this.showHint,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      backgroundMusicEnabled: backgroundMusicEnabled ?? this.backgroundMusicEnabled,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    boardTheme,
    pieceStyle,
    clockStyle,
    highlightMove,
    showHint,
    soundEnabled,
    backgroundMusicEnabled,
    darkMode,
  ];
}
