import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:asmrapp/core/subtitle/i_subtitle_service.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'lyric_line.dart';

class PlayerLyricView extends StatefulWidget {
  const PlayerLyricView({super.key});

  @override
  State<PlayerLyricView> createState() => _PlayerLyricViewState();
}

class _PlayerLyricViewState extends State<PlayerLyricView> {
  final ISubtitleService _subtitleService = GetIt.I<ISubtitleService>();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  
  // 添加标记，记录是否是首次滚动
  bool _isFirstScroll = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentSubtitle = _subtitleService.currentSubtitleWithState;
      if (currentSubtitle != null) {
        _itemScrollController.jumpTo(
          index: currentSubtitle.subtitle.index,
          alignment: 0.5,
        );
      }
    });
  }
  
  void _scrollToCurrentLyric(SubtitleWithState current) {
    if (!_itemScrollController.isAttached) return;
    
    if (_isFirstScroll) {
      _isFirstScroll = false;
      return; // 跳过首次滚动，因为 initState 已经处理了
    }
    
    _itemScrollController.scrollTo(
      index: current.subtitle.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      alignment: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    final screenHeight = MediaQuery.of(context).size.height;
    // 计算基础单位，以屏幕高度为基准
    final baseUnit = screenHeight * 0.04;  // 4% 的屏幕高度
    
    return StreamBuilder<SubtitleWithState?>(
      stream: _subtitleService.currentSubtitleWithStateStream,
      initialData: _subtitleService.currentSubtitleWithState,
      builder: (context, snapshot) {
        final currentSubtitle = snapshot.data;
        final subtitleList = _subtitleService.subtitleList;

        if (subtitleList == null || subtitleList.subtitles.isEmpty) {
          return const Center(
            child: Text('无歌词'),
          );
        }

        // 当前歌词变化时，自动滚动
        if (currentSubtitle != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToCurrentLyric(currentSubtitle);
          });
        }

        return ScrollablePositionedList.builder(
          itemCount: subtitleList.subtitles.length,
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.3,  // 增加上下边距到 30%
            horizontal: baseUnit * 0.8,
          ),
          itemBuilder: (context, index) {
            final subtitle = subtitleList.subtitles[index];
            final isActive = currentSubtitle?.subtitle == subtitle;
            
            return SizedBox(
              height: baseUnit * 1.6,  // 增加行高到 1.6 倍基础单位
              child: Center(
                child: LyricLine(
                  subtitle: subtitle,
                  isActive: isActive,
                  opacity: isActive ? 1.0 : 0.5,
                ),
              ),
            );
          },
        );
      },
    );
  }
} 