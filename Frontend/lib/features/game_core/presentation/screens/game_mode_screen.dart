import 'package:chess_app/core/config/size_config.dart';
import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/dimens/dimens.dart';
import 'package:chess_app/core/routes/route_constants.dart';
import 'package:chess_app/core/style/app_text_style.dart';
import 'package:chess_app/features/game_core/presentation/screens/game_detail_screen.dart';
import 'package:chess_app/features/game_core/presentation/widgets/game_mode_card.dart';
import 'package:chess_app/features/game_core/presentation/widgets/game_drawer.dart';
import 'package:chess_app/gen/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameModeScreen extends StatelessWidget {
  const GameModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppDimen.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'app_title'.tr(),
                style: AppTextStyles.style.s22.w800.blackColor,
              ),
              const SizedBox(width: 4),
              Assets.svgs.chessLogo.svg(),
            ],
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "Chế độ chơi"),
              Tab(text: "Lịch sử đấu"),
            ],
          ),
        ),
        drawer: const GameDrawer(),
        body: const TabBarView(
          children: [
            _GameModeBody(),
            _GameHistoryTab(),
          ],
        ),
      ),
    );
  }
}

/// TAB 1: Chế độ chơi
class _GameModeBody extends StatelessWidget {
  const _GameModeBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d20.responsive(),
          vertical: Dimens.d12.responsive(),
        ),
        child: Column(
          children: [
            VerticalSpacing(of: Dimens.d8.responsive()),
            GameModeCard(
              image: Assets.images.logo1p.path,
              title: 'one_player'.tr(),
              subtitle: 'one_player_sub'.tr(),
              onTap: () => context.push(RouteConstants.botGameSetup),
            ),
            VerticalSpacing(of: Dimens.d16.responsive()),
            GameModeCard(
              image: Assets.images.logo2p.path,
              title: 'two_player'.tr(),
              subtitle: 'two_player_sub'.tr(),
              onTap: () => context.push(RouteConstants.twoPlayer),
            ),
            VerticalSpacing(of: Dimens.d16.responsive()),
            GameModeCard(
              image: Assets.images.logoPuzzles.path,
              title: 'puzzles'.tr(),
              subtitle: 'puzzles_sub'.tr(),
              onTap: () => context.push(RouteConstants.puzzles),
            ),
          ],
        ),
      ),
    );
  }
}

/// TAB 2: Lịch sử đấu
class _GameHistoryTab extends StatelessWidget {
  const _GameHistoryTab();

  @override
  Widget build(BuildContext context) {
    final mockGames = [
      {"id": 1, "title": "Trận với Bot (Dễ)", "result": "Thắng", "date": "08/11/2025"},
      {"id": 2, "title": "Trận 2 người", "result": "Thua", "date": "06/11/2025"},
      {"id": 3, "title": "Puzzles 5", "result": "Hoàn thành", "date": "02/11/2025"},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockGames.length,
      itemBuilder: (context, index) {
        final game = mockGames[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            title: Text("${game['title']}"),
            subtitle: Text("Kết quả: ${game['result']} - ${game['date']}"),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: game['id'] as int)),
              );
            },
          ),
        );
      },
    );
  }
}