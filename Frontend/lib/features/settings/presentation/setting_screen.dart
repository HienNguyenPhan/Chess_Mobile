import 'package:chess_app/core/di/injection_container.dart';
import 'package:chess_app/core/style/app_text_style.dart';
import 'package:chess_app/features/settings/bloc/setting_bloc.dart';
import 'package:chess_app/features/settings/presentation/widgets/setting_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<SettingBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'settings'.tr(),
            style: AppTextStyles.style.s18.w600.blackColor,
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        body: BlocBuilder<SettingBloc, SettingState>(
          builder: (context, state) {
            final bloc = context.read<SettingBloc>();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🎨 BOARD THEME
                Text(
                  '🎨 ${'board_theme'.tr()}',
                  style: AppTextStyles.style.s16.w600.blackColor,
                ),
                SettingTile.dropdown(
                  title: 'board_color_theme'.tr(),
                  dropdownValue: state.boardTheme, // ex: 'theme_classic'
                  options: const [
                    'theme_classic',
                    'theme_wood',
                    'theme_marble',
                    'theme_blue',
                    'theme_bw',
                  ],
                  onDropdownChanged: (v) => bloc.add(ChangeBoardThemeEvent(v!)),
                ),

                SettingTile.dropdown(
                  title: 'piece_style'.tr(),
                  dropdownValue: state.pieceStyle,
                  options: [
                    'style_classic',
                    'style_minimal',
                    'style_fantasy',
                  ],
                  onDropdownChanged: (v) => bloc.add(ChangePieceStyleEvent(v!)),
                ),
                SettingTile.dropdown(
                  title: 'clock_style'.tr(),
                  dropdownValue: state.clockStyle,
                  options: ['clock_digital', 'clock_analog'],
                  onDropdownChanged: (v) => bloc.add(ChangeClockStyleEvent(v!)),
                ),

                const Divider(),

                // ⚙️ OPTIONS
                Text(
                  '⚙️ ${'options'.tr()}',
                  style: AppTextStyles.style.s16.w600.blackColor,
                ),
                SettingTile.switchTile(
                  title: 'highlight_moves'.tr(),
                  value: state.highlightMove,
                  onChanged: (_) =>
                      bloc.add(ToggleSettingEvent(ToggleType.highlightMove)),
                ),
                // SettingTile.switchTile(
                //   title: 'show_move_hints'.tr(),
                //   value: state.showHint,
                //   onChanged: (_) =>
                //       bloc.add(ToggleSettingEvent(ToggleType.hintMove)),
                // ),
                // // Sound Effects
                SettingTile.switchTile(
                  title: 'move_sound'.tr(),
                  value: state.soundEnabled,
                  onChanged: (_) =>
                      bloc.add(ToggleSettingEvent(ToggleType.sound)),
                ),
                // Background Music
                SettingTile.switchTile(
                  title: 'background_music'.tr(),
                  value: state.backgroundMusicEnabled,
                  onChanged: (_) {
                    print('Background music toggled: ${!state.backgroundMusicEnabled}');
                    bloc.add(ToggleSettingEvent(ToggleType.backgroundMusic));
                  },
                ),
                // SettingTile.switchTile(
                //   title: 'dark_mode'.tr(),
                //   value: state.darkMode,
                //   onChanged: (_) =>
                //       bloc.add(ToggleSettingEvent(ToggleType.darkMode)),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}
