import 'dart:async';

import 'package:asmrapp/core/platform/i_lyric_overlay_controller.dart';
import 'package:asmrapp/core/subtitle/i_subtitle_service.dart';
import 'package:flutter/material.dart';

class LyricOverlayManager {
  final ILyricOverlayController _controller;
  final ISubtitleService _subtitleService;
  StreamSubscription? _subscription;
  
  LyricOverlayManager({
    required ILyricOverlayController controller,
    required ISubtitleService subtitleService,
  }) : _controller = controller,
       _subtitleService = subtitleService;

  Future<void> initialize() async {
    await _controller.initialize();
    _subscription = _subtitleService.currentSubtitleStream.listen((subtitle) {
      _controller.updateLyric(subtitle?.text);
    });
  }
  
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.dispose();
  }
  
  Future<bool> checkPermission() async {
    return await _controller.checkPermission();
  }

  Future<bool> requestPermission() async {
    return await _controller.requestPermission();
  }

  Future<void> show() async {
    await _controller.show();
  }

  Future<void> hide() async {
    await _controller.hide();
  }
  
  /// 处理显示悬浮歌词的完整流程
  Future<void> showWithPermissionCheck(BuildContext context) async {
    final hasPermission = await checkPermission();
    if (hasPermission) {
      await show();
      return;
    }

    if (!context.mounted) return;

    final shouldRequest = await _showPermissionDialog(context);
    if (shouldRequest && context.mounted) {
      final granted = await requestPermission();
      if (granted && context.mounted) {
        await show();
      }
    }
  }

  Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开启悬浮歌词'),
        content: const Text('需要悬浮窗权限来显示歌词，是否授予权限？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  // 其他控制方法...
} 