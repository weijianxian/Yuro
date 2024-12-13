import 'package:flutter/material.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'package:asmrapp/core/subtitle/i_subtitle_service.dart';
import 'package:get_it/get_it.dart';
import 'components/lyric_context.dart';

class LyricDisplay extends StatelessWidget {
  final ISubtitleService _subtitleService = GetIt.I<ISubtitleService>();

  LyricDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Subtitle?>(
      stream: _subtitleService.currentSubtitleStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 120);
        }

        final currentSubtitle = snapshot.data!;
        final subtitleList = _subtitleService.subtitleList;
        
        if (subtitleList == null) {
          return const SizedBox(height: 120);
        }

        final (previous, _, next) = subtitleList.getCurrentContext();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          constraints: const BoxConstraints(minHeight: 120),
          child: LyricContext(
            previous: previous,
            current: currentSubtitle,
            next: next,
          ),
        );
      },
    );
  }
} 