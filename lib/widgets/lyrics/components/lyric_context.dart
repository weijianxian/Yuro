import 'package:flutter/material.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'lyric_line.dart';

class LyricContext extends StatelessWidget {
  final Subtitle? previous;
  final Subtitle? current;
  final Subtitle? next;
  final SubtitleState? state;
  final bool isWaiting;

  const LyricContext({
    super.key,
    this.previous,
    this.current,
    this.next,
    this.state,
    this.isWaiting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (previous != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LyricLine(
              subtitle: previous!,
              opacity: 0.5,
              isActive: false,
            ),
          ),
        if (current != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LyricLine(
              subtitle: current!,
              opacity: state == SubtitleState.waiting ? 0.3 : 1.0,
              isActive: state == SubtitleState.current,
            ),
          ),
        if (next != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LyricLine(
              subtitle: next!,
              opacity: 0.5,
              isActive: false,
            ),
          ),
      ],
    );
  }
}
