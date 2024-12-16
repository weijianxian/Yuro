import 'package:asmrapp/core/platform/lyric_overlay_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/presentation/viewmodels/player_viewmodel.dart';
import 'package:asmrapp/widgets/player/player_controls.dart';
import 'package:asmrapp/widgets/player/player_progress.dart';
import 'package:asmrapp/widgets/lyrics/lyric_display.dart';
import 'package:asmrapp/widgets/player/player_cover.dart';


class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    final lyricManager = GetIt.I<LyricOverlayManager>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.expand_more),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // 封面
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: PlayerCover(
                    coverUrl: viewModel.currentTrackInfo?.coverUrl,
                  ),
                ),
                const SizedBox(height: 32),
                // 标题和艺术家
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        viewModel.currentTrackInfo?.title ?? '未在播放',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (viewModel.currentTrackInfo?.artist != null)
                        Text(
                          viewModel.currentTrackInfo!.artist,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 字幕显示
                const Expanded(
                  child: LyricDisplay(),
                ),
                // 底部控制区域
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      PlayerProgress(),
                      SizedBox(height: 24),
                      PlayerControls(),
                      SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
