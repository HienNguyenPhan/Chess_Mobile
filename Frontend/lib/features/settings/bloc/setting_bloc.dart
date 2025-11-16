import 'package:chess_app/core/data/enum/status_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chess_app/core/services/audio_service.dart';
part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  late final AudioService _audioService;

  SettingBloc() : super(SettingState.initial()) {
    on<LoadSettingsEvent>(_onLoad);
    on<ChangeBoardThemeEvent>(_onChangeBoardTheme);
    on<ChangePieceStyleEvent>(_onChangePieceStyle);
    on<ChangeClockStyleEvent>(_onChangeClockStyle);
    on<ToggleSettingEvent>(_onToggle);

    _audioService = GetIt.I<AudioService>();
    // Load settings khi khởi tạo bloc
    add(LoadSettingsEvent());
  }

  Future<void> _onLoad(
    LoadSettingsEvent event,
    Emitter<SettingState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    final backgroundMusicEnabled = prefs.getBool('backgroundMusicEnabled') ?? true;
    
    emit(
      state.copyWith(
        boardTheme: prefs.getString('boardTheme') ?? 'theme_classic',
        pieceStyle: prefs.getString('pieceStyle') ?? 'style_classic',
        clockStyle: prefs.getString('clockStyle') ?? 'clock_digital',
        highlightMove: prefs.getBool('highlightMove') ?? true,
        showHint: prefs.getBool('showHint') ?? true,
        soundEnabled: prefs.getBool('soundEnabled') ?? true,
        backgroundMusicEnabled: backgroundMusicEnabled,
        darkMode: prefs.getBool('darkMode') ?? false,
      ),
    );

    // Đồng bộ trạng thái âm nhạc với setting
    if (backgroundMusicEnabled) {
      _audioService.playBackgroundMusic();
    } else {
      _audioService.stopBackgroundMusic();
    }
  }

  Future<void> _onChangeBoardTheme(
    ChangeBoardThemeEvent e,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(boardTheme: e.theme));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('boardTheme', e.theme);
  }

  Future<void> _onChangePieceStyle(
    ChangePieceStyleEvent e,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(pieceStyle: e.style));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pieceStyle', e.style);
  }

  Future<void> _onChangeClockStyle(
    ChangeClockStyleEvent e,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(clockStyle: e.style));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clockStyle', e.style);
  }

  Future<void> _onToggle(
    ToggleSettingEvent event,
    Emitter<SettingState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    switch (event.type) {
      case ToggleType.highlightMove:
        emit(state.copyWith(highlightMove: !state.highlightMove));
        prefs.setBool('highlightMove', !state.highlightMove);
        break;
      case ToggleType.hintMove:
        emit(state.copyWith(showHint: !state.showHint));
        prefs.setBool('showHint', !state.showHint);
        break;
      case ToggleType.sound:
        emit(state.copyWith(soundEnabled: !state.soundEnabled));
        prefs.setBool('soundEnabled', !state.soundEnabled);
        break;
      case ToggleType.backgroundMusic:
        print('Processing background music toggle in bloc');
        print('Current state: ${state.backgroundMusicEnabled}');
        
        // Lấy giá trị mới và cập nhật state trước
        final newValue = !state.backgroundMusicEnabled;
        print('New value will be: $newValue');
        
        // Lưu vào SharedPreferences
        await prefs.setBool('backgroundMusicEnabled', newValue);
        
        try {
          // Emit state trước khi xử lý âm nhạc
          emit(state.copyWith(
            backgroundMusicEnabled: newValue,
            status: StatusEnum.success,
          ));
          print('State emitted with new value: $newValue');
          
          // Xử lý âm nhạc sau khi state đã được cập nhật
          if (newValue) {
            print('Attempting to play background music');
            await _audioService.playBackgroundMusic();
            print('Background music should be playing now');
          } else {
            print('Stopping background music');
            await _audioService.stopBackgroundMusic();
            print('Background music should be stopped');
          }
        } catch (e) {
          print('Error handling background music: $e');
          // Emit error state nếu có lỗi
          emit(state.copyWith(status: StatusEnum.failure));
        }
        break;
      case ToggleType.darkMode:
        emit(state.copyWith(darkMode: !state.darkMode));
        prefs.setBool('darkMode', !state.darkMode);
        break;
    }

  }
}
