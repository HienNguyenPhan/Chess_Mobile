import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:chess_app/features/settings/bloc/setting_bloc.dart';

class AudioService {
  late final AudioPlayer _bgmPlayer;
  late final AudioPlayer _sfxPlayer;
  bool _isBgmPlaying = false;

  // Singleton instance
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
  }

  Future<void> init() async {
    try {
      print('Initializing AudioService...');
      
      // Reset trạng thái
      _isBgmPlaying = false;
      await _bgmPlayer.stop();
      
      // Cài đặt cơ bản cho background music player
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.3);
      await _bgmPlayer.setSource(AssetSource('audio/chess_bgm.mp3'));
      
      // Cài đặt cho sound effect player
      await _sfxPlayer.setVolume(0.5);
      
      print('AudioService initialized successfully');
      
      // Kiểm tra setting và phát nhạc nếu cần
      final settingBloc = GetIt.I<SettingBloc>();
      if (settingBloc.state.backgroundMusicEnabled) {
        await Future.delayed(const Duration(milliseconds: 500));
        await playBackgroundMusic();
      }
    } catch (e) {
      print('Error initializing audio service: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> playBackgroundMusic() async {
    final settingBloc = GetIt.I<SettingBloc>();
    print('Current BGM state - Playing: $_isBgmPlaying, Enabled in settings: ${settingBloc.state.backgroundMusicEnabled}');

    if (_isBgmPlaying) {
      print('BGM is already playing, skipping...');
      return;
    }

    try {
      print('Attempting to play BGM');
      if (settingBloc.state.backgroundMusicEnabled) {
        print('Playing BGM from asset');
        
        try {
          // Đảm bảo dừng và reset trước khi phát
          await _bgmPlayer.stop();
          await _bgmPlayer.seek(Duration.zero);
          
          // Set source và volume
          await _bgmPlayer.setSource(AssetSource('audio/chess_bgm.mp3'));
          await _bgmPlayer.setVolume(0.3);
          
          // Phát nhạc
          await _bgmPlayer.resume();
          _isBgmPlaying = true;
          print('BGM started playing successfully');
        } catch (e) {
          print('Error during playback setup: $e');
          _isBgmPlaying = false;
          rethrow;
        }
      } else {
        print('BGM is disabled in settings (current setting state: ${settingBloc.state.backgroundMusicEnabled})');
      }
    } catch (e) {
      print('Error playing background music: $e');
      print('Stack trace: ${StackTrace.current}');
      _isBgmPlaying = false;  // Reset state nếu có lỗi
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      print('Stopping BGM, current state: $_isBgmPlaying');
      if (_isBgmPlaying) {
        await _bgmPlayer.stop();  // Sử dụng stop thay vì pause
        _isBgmPlaying = false;
        print('BGM stopped, _isBgmPlaying: $_isBgmPlaying');
      }
    } catch (e) {
      print('Error stopping background music: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      if (_isBgmPlaying) {
        await _bgmPlayer.pause();
        _isBgmPlaying = false;
        print('BGM paused');
      }
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    try {
      final settingBloc = GetIt.I<SettingBloc>();
      if (!_isBgmPlaying && settingBloc.state.backgroundMusicEnabled) {
        await _bgmPlayer.resume();
        _isBgmPlaying = true;
        print('BGM resumed');
      }
    } catch (e) {
      print('Error resuming background music: $e');
      _isBgmPlaying = false;  // Reset state nếu có lỗi
    }
  }

  Future<void> playMoveSound() async {
    try {
      if (GetIt.I<SettingBloc>().state.soundEnabled) {
        await _sfxPlayer.play(AssetSource('audio/move.mp3'));
      }
    } catch (e) {
      debugPrint('Error playing move sound: $e');
    }
  }

  Future<void> playCaptureSound() async {
    try {
      if (GetIt.I<SettingBloc>().state.soundEnabled) {
        await _sfxPlayer.play(AssetSource('audio/capture.mp3'));
      }
    } catch (e) {
      debugPrint('Error playing capture sound: $e');
    }
  }

  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}