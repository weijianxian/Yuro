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
  SubtitleWithState? _lastSubtitleWithState;

  @override
  void initState() {
    super.initState();
    _initCurrentSubtitle();
  }

  void _initCurrentSubtitle() {
    final subtitleList = _subtitleService.subtitleList;
    if (subtitleList != null) {
      // 获取当前字幕
      _lastSubtitleWithState = _subtitleService.currentSubtitleWithState;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SubtitleWithState?>(
      stream: _subtitleService.currentSubtitleWithStateStream,
      builder: (context, snapshot) {
        final currentSubtitleWithState = snapshot.data;
        final subtitleList = _subtitleService.subtitleList;
        
        // 当没有新字幕时，使用已保存的字幕
        if (currentSubtitleWithState == null && _lastSubtitleWithState != null) {
          return _buildLyricContext(_lastSubtitleWithState, subtitleList);
        }

        // 更新最后显示的字幕
        if (currentSubtitleWithState != null) {
          _lastSubtitleWithState = currentSubtitleWithState;
        }

        return _buildLyricContext(currentSubtitleWithState ?? _lastSubtitleWithState, subtitleList);
      },
    );
  }

  Widget _buildLyricContext(SubtitleWithState? current, SubtitleList? subtitleList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 如果没有字幕列表，返回空容器
        if (subtitleList == null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          );
        }

        // 如果没有当前字幕但有字幕列表，显示第一句
        if (current == null && subtitleList.subtitles.isNotEmpty) {
          return OverflowBox(
            minHeight: 0,
            maxHeight: double.infinity,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: LyricContext(
                  current: subtitleList.subtitles.first,
                  isWaiting: true,
                ),
              ),
            ),
          );
        }
        
        return OverflowBox(
          minHeight: 0,
          maxHeight: double.infinity,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: LyricContext(
                previous: current?.subtitle.getPrevious(subtitleList),
                current: current?.subtitle,
                next: current?.subtitle.getNext(subtitleList),
                state: current?.state,
              ),
            ),
          ),
        );
      },
    );
  }
} 