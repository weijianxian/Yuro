import 'package:flutter/material.dart';

class WorkActions extends StatelessWidget {
  final VoidCallback? onDownload;
  final VoidCallback? onPlay;

  const WorkActions({
    super.key,
    this.onDownload,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download),
            label: const Text('下载'),
          ),
          TextButton.icon(
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow),
            label: const Text('播放'),
          ),
        ],
      ),
    );
  }
}
