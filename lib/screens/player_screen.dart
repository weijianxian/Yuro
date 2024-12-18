import 'package:asmrapp/core/platform/lyric_overlay_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/presentation/viewmodels/player_viewmodel.dart';
import 'package:asmrapp/widgets/player/player_controls.dart';
import 'package:asmrapp/widgets/player/player_progress.dart';
import 'package:asmrapp/widgets/player/player_cover.dart';
import 'package:asmrapp/screens/detail_screen.dart';
import 'package:asmrapp/widgets/player/player_seek_controls.dart';
import 'package:asmrapp/widgets/lyrics/components/player_lyric_view.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showLyrics = false;
  final GlobalKey _contentKey = GlobalKey();

  Widget _buildContent(PlayerViewModel viewModel) {
    if (_showLyrics) {
      return LayoutBuilder(
        key: _contentKey,
        builder: (context, constraints) {
          return PlayerLyricView();
        },
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        // 封面
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Hero(
            tag:
                'player-cover-${viewModel.currentContext?.work.id ?? "default"}',
            child: PlayerCover(
              coverUrl: viewModel.currentTrackInfo?.coverUrl,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // 标题和艺术家
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Hero(
                tag: 'player-title',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    viewModel.currentTrackInfo?.title ?? '未在播放',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (viewModel.currentTrackInfo?.artist != null)
                Text(
                  viewModel.currentTrackInfo!.artist,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ],
    );
  }

  double _getBottomBarHeight() {
    return 32 + 8 + 48 + 8 + 48;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    final lyricManager = GetIt.I<LyricOverlayManager>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.expand_more),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              final currentWork = viewModel.currentContext?.work;
              if (currentWork != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      work: currentWork,
                      fromPlayer: true,
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              lyricManager.isShowing ? Icons.lyrics : Icons.lyrics_outlined,
            ),
            onPressed: () => lyricManager.toggle(context),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showLyrics = !_showLyrics;
                  });
                },
                child: _buildContent(viewModel),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
              child: Column(
                children: const [
                  PlayerProgress(),
                  SizedBox(height: 8),
                  // PlayerSeekControls(), // 暂时移除进度控制按钮
                  // 原因:
                  // 1. 当前按钮过多(6个)导致操作复杂
                  // 2. 需要重新设计主次分明的控制界面
                  // 3. 计划将部分功能改为手势操作
                  // TODO: 重新设计更简洁的控制界面
                  SizedBox(height: 8),
                  PlayerControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
