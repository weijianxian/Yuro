import 'package:flutter/material.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'lyric_line.dart';

class LyricContext extends StatelessWidget {
  final Subtitle? previous;
  final Subtitle? current;
  final Subtitle? next;
  final bool isWaiting;

  const LyricContext({
    super.key,
    this.previous,
    this.current,
    this.next,
    this.isWaiting = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isWaiting && current != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: LyricLine(
                      subtitle: current!,
                      opacity: 0.3,
                      isActive: false,
                    ),
                  )
                else ...[
                  if (previous != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: LyricLine(
                        subtitle: previous!,
                        opacity: 0.5,
                      ),
                    ),
                  if (current != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: LyricLine(
                        subtitle: current!,
                        isActive: true,
                      ),
                    ),
                  if (next != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: LyricLine(
                        subtitle: next!,
                        opacity: 0.5,
                      ),
                    ),
                ],
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 8,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
