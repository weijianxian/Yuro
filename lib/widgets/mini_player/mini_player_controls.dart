import 'package:flutter/material.dart';
import 'package:asmrapp/presentation/viewmodels/mini_player_viewmodel.dart';
import 'package:get_it/get_it.dart';

class MiniPlayerControls extends StatelessWidget {
  const MiniPlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = GetIt.I<MiniPlayerViewModel>();
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return IconButton(
          icon: Icon(
            viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: viewModel.togglePlayPause,
        );
      },
    );
  }
} 