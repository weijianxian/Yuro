import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:asmrapp/core/subtitle/i_subtitle_service.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'lyric_line.dart';

class PlayerLyricView extends StatefulWidget {
  final bool immediateScroll;

  const PlayerLyricView({
    super.key,
    this.immediateScroll = false,
  });

  @override
  State<PlayerLyricView> createState() => _PlayerLyricViewState();
}

class _PlayerLyricViewState extends State<PlayerLyricView> {
  final ISubtitleService _subtitleService = GetIt.I<ISubtitleService>();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  
  // 添加一个标记，记录是否是首次构建
  bool _isFirstBuild = true;
  Subtitle? _lastScrolledSubtitle;
  
  @override
  void initState() {
    super.initState();
    // 移除 initState 中的滚动逻辑，统一在 build 中处理
  }
  
  void _scrollToCurrentLyric(SubtitleWithState current) {
    if (!_itemScrollController.isAttached) return;
    
    // 避免重复滚动
    if (_lastScrolledSubtitle == current.subtitle) return;
    _lastScrolledSubtitle = current.subtitle;
    
    // 首次构建时直接跳转到位置，不使用动画
    if (_isFirstBuild) {
      _isFirstBuild = false;
      _itemScrollController.jumpTo(
        index: current.subtitle.index,
        alignment: 0.5,
      );
    } else {
      // 后续的歌词切换使用动画
      _itemScrollController.scrollTo(
        index: current.subtitle.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        alignment: 0.5,
      );
    }
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
            
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: baseUnit * 0.35,  // 改用padding来控制行间距
              ),
              child: LyricLine(
                subtitle: subtitle,
                isActive: isActive,
                opacity: isActive ? 1.0 : 0.5,
              ),
            );
          },
        );
      },
    );
  }
} 