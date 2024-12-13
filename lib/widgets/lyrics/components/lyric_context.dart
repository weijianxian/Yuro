import 'package:flutter/material.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'lyric_line.dart';

class LyricContext extends StatelessWidget {
  final Subtitle? previous;
  final Subtitle? current;
  final Subtitle? next;

  const LyricContext({
    super.key,
    this.previous,
    this.current,
    this.next,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (previous != null)
          LyricLine(
            subtitle: previous!,
            opacity: 0.5,
          ),
        if (current != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: LyricLine(
              subtitle: current!,
              isActive: true,
            ),
          ),
        if (next != null)
          LyricLine(
            subtitle: next!,
            opacity: 0.5,
          ),
      ],
    );
  }
} 