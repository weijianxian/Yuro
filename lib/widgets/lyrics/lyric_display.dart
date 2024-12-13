import 'package:flutter/material.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'package:asmrapp/core/subtitle/i_subtitle_service.dart';
import 'package:get_it/get_it.dart';
import 'components/lyric_context.dart';

class LyricDisplay extends StatefulWidget {
  const LyricDisplay({super.key});

  @override
  State<LyricDisplay> createState() => _LyricDisplayState();
}

class _LyricDisplayState extends State<LyricDisplay> {
  final ISubtitleService _subtitleService = GetIt.I<ISubtitleService>();
  Subtitle? _lastSubtitle;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Subtitle?>(
      stream: _subtitleService.currentSubtitleStream,
      builder: (context, snapshot) {
        final currentSubtitle = snapshot.data;
        final subtitleList = _subtitleService.subtitleList;
        
        // 当没有新字幕时，保持显示上一句
        if (currentSubtitle == null && _lastSubtitle != null) {
          return _buildLyricContext(_lastSubtitle, subtitleList);
        }

        // 更新最后显示的字幕
        if (currentSubtitle != null) {
          _lastSubtitle = currentSubtitle;
        }

        return _buildLyricContext(currentSubtitle, subtitleList);
      },
    );
  }

  Widget _buildLyricContext(Subtitle? current, SubtitleList? subtitleList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算可用空间，考虑到进度条和控制按钮的空间
        final availableHeight = constraints.maxHeight;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          constraints: BoxConstraints(
            minHeight: 80,
            maxHeight: availableHeight,  // 使用可用空间作为最大高度
          ),
          child: LyricContext(
            previous: current?.getPrevious(subtitleList!),
            current: current,
            next: current?.getNext(subtitleList!),
          ),
        );
      },
    );
  }
} 