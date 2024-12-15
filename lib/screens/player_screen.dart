import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/presentation/viewmodels/player_viewmodel.dart';
import 'package:asmrapp/widgets/player/player_controls.dart';
import 'package:asmrapp/widgets/player/player_progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:asmrapp/widgets/lyrics/lyric_display.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.expand_more),
          onPressed: () => Navigator.pop(context),
        ),
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
                  child: AspectRatio(
                    aspectRatio: 4/3,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 480, // 限制最大宽度
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12), // 稍微增大圆角
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: viewModel.currentTrack?.coverUrl != null
                            ? CachedNetworkImage(
                                imageUrl: viewModel.currentTrack!.coverUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  highlightColor: Theme.of(context).colorScheme.surface,
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Theme.of(context).colorScheme.errorContainer,
                                  child: Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              )
                            : const Icon(Icons.music_note, size: 100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // 标题和艺术家
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        viewModel.currentTrack?.title ?? '未在播放',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (viewModel.currentTrack?.artist != null)
                        Text(
                          viewModel.currentTrack!.artist,
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
