import 'package:flutter/material.dart';
import 'package:asmrapp/presentation/viewmodels/player_viewmodel.dart';
import 'mini_player_controls.dart';
import 'mini_player_progress.dart';
import 'package:get_it/get_it.dart';
import 'mini_player_cover.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<PlayerViewModel>();
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Column(
            children: [
              const MiniPlayerProgress(),
              Expanded(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      child: MiniPlayerCover(
                        coverUrl: viewModel.currentTrack?.coverUrl,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.currentTrack?.title ?? '未在播放',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (viewModel.currentTrack?.artist != null)
                              Text(
                                viewModel.currentTrack!.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const MiniPlayerControls(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 