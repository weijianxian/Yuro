import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/presentation/viewmodels/player_viewmodel.dart';
import 'package:asmrapp/widgets/player/player_controls.dart';
import 'package:asmrapp/widgets/player/player_progress.dart';

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
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: viewModel.currentTrack?.coverUrl != null
                      ? Image.network(
                          viewModel.currentTrack!.coverUrl,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.music_note, size: 100),
                ),
                const SizedBox(height: 32),
                // 标题和艺术家
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        viewModel.currentTrack?.title ?? '未在播放',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      if (viewModel.currentTrack?.artist != null)
                        Text(
                          viewModel.currentTrack!.artist,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                // 字幕显示
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  constraints: const BoxConstraints(minHeight: 60),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      viewModel.currentSubtitle?.text ?? '',
                      key: ValueKey(viewModel.currentSubtitle?.text),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const PlayerProgress(),
                const SizedBox(height: 24),
                const PlayerControls(),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}
