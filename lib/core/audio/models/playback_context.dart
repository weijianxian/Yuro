import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:asmrapp/core/audio/models/play_mode.dart';
import 'package:asmrapp/core/audio/models/file_path.dart';

class PlaybackContext {
  final Work work;
  final Files files;
  final Child currentFile;
  final List<Child> playlist;
  final int currentIndex;
  final PlayMode playMode;

  // 私有构造函数
  const PlaybackContext._({
    required this.work,
    required this.files,
    required this.currentFile,
    required this.playlist,
    required this.currentIndex,
    this.playMode = PlayMode.sequence,
  });

  // 公开的工厂构造函数，只需要基本参数
  factory PlaybackContext({
    required Work work,
    required Files files,
    required Child currentFile,
    PlayMode playMode = PlayMode.sequence,
  }) {
    final playlist = _getPlaylistFromSameDirectory(currentFile, files);
    final currentIndex = playlist.indexWhere((file) => file.title == currentFile.title);
    
    return PlaybackContext._(
      work: work,
      files: files,
      currentFile: currentFile,
      playlist: playlist,
      currentIndex: currentIndex,
      playMode: playMode,
    );
  }

  // 获取同级文件列表
  static List<Child> _getPlaylistFromSameDirectory(Child currentFile, Files files) {
    AppLogger.debug('开始获取播放列表...');
    AppLogger.debug('当前文件: ${currentFile.title}');
    AppLogger.debug('当前文件类型: ${currentFile.type}');

    // 获取当前文件的扩展名
    final extension = currentFile.title?.split('.').last.toLowerCase();
    AppLogger.debug('当前文件扩展名: $extension');
    
    if (extension != 'mp3' && extension != 'wav') {
      AppLogger.debug('不支持的文件类型: $extension');
      return [];
    }

    // 使用 FilePath 获取同级文件
    final siblings = FilePath.getSiblings(currentFile, files);
    
    // 过滤出相同扩展名的文件
    final playlist = siblings.where((file) => 
      file.title?.toLowerCase().endsWith('.$extension') ?? false
    ).toList();
    
    AppLogger.debug('找到 ${playlist.length} 个可播放文件:');
    for (var file in playlist) {
      AppLogger.debug('- [${file.type}] ${file.title} (URL: ${file.mediaDownloadUrl != null ? '有' : '无'})');
    }
    
    return playlist;
  }

  // 递归查找文件所在的目录
  static List<Child>? _findParentDirectory(List<Child>? children, Child targetFile) {
    if (children == null) {
      AppLogger.debug('当前目录为空');
      return null;
    }

    AppLogger.debug('正在搜索目录，查找文件: ${targetFile.title}');
    AppLogger.debug('当前目录内容:');
    for (var file in children) {
      AppLogger.debug('- [${file.type}] ${file.title}');
    }

    // 如果当前目录包含目标文件，返回当前目录
    if (children.any((file) => file.title == targetFile.title)) {
      AppLogger.debug('✓ 在当前目录找到目标文件');
      return children;
    }

    // 递归查找子目录
    for (var child in children) {
      if (child.type == 'folder' && child.children != null) {
        AppLogger.debug('进入子文件夹: ${child.title}');
        final result = _findParentDirectory(child.children, targetFile);
        if (result != null) {
          AppLogger.debug('在文件夹 ${child.title} 中找到目标文件');
          return result;
        }
        AppLogger.debug('未在文件夹 ${child.title} 中找到目标文件，继续搜索');
      }
    }

    AppLogger.debug('在当前目录及其子目录中未找到目标文件');
    return null;
  }

  // 便捷方法：检查是否有下一曲
  bool get hasNext => currentIndex < playlist.length - 1;

  // 便捷方法：检查是否有上一曲
  bool get hasPrevious => currentIndex > 0;

  // 获取下一曲（考虑播放模式）
  Child? getNextFile() {
    if (playlist.isEmpty) return null;
    
    switch (playMode) {
      case PlayMode.single:
        return currentFile;  // 单曲循环返回当前文件
      case PlayMode.loop:
        // 列表循环：最后一首返回第一首，否则返回下一首
        return hasNext ? playlist[currentIndex + 1] : playlist[0];
      case PlayMode.sequence:
        // 顺序播放：有下一首则返回，否则返回null
        return hasNext ? playlist[currentIndex + 1] : null;
    }
  }

  // 获取上一曲
  Child? getPreviousFile() {
    if (playlist.isEmpty) return null;
    
    switch (playMode) {
      case PlayMode.single:
        return currentFile;
      case PlayMode.loop:
        // 列表循环：第一首返回最后一首，否则返回上一首
        return hasPrevious ? playlist[currentIndex - 1] : playlist[playlist.length - 1];
      case PlayMode.sequence:
        // 顺序播放：有上一首则返回，否则返回null
        return hasPrevious ? playlist[currentIndex - 1] : null;
    }
  }

  // 这两个方法 copy 的设计思路是遵循了"不可变对象"模式，
  // 通过创建新的实例而不是修改现有实例来更新状态。这种模式有以下好处：
  // 状态可预测
  // 线程安全
  // 便于调试
  // 符合函数式编程思想

  // 创建新的上下文（用于切换文件）
  PlaybackContext copyWithFile(Child newFile) {
    return PlaybackContext(
      work: work,
      files: files,
      currentFile: newFile,
      playMode: playMode,
    );
  }

  // 创建新的上下文（用于切换播放模式）
  PlaybackContext copyWithMode(PlayMode newMode) {
    return PlaybackContext(
      work: work,
      files: files,
      currentFile: currentFile,
      playMode: newMode,
    );
  }

  // 便捷方法：获取字幕文件
  Child? getSubtitleFile() {
    if (files.children == null || currentFile.title == null) {
      debugPrint('无法查找字幕文件: ${files.children == null ? '文件列表为空' : '当前文件名为空'}');
      return null;
    }
    
    debugPrint('开始递归查找字幕文件...');
    return _findSubtitleInDirectory(files.children!, currentFile.title!);
  }

  // 递归查找字幕文件
  Child? _findSubtitleInDirectory(List<Child> children, String audioFileName) {
    debugPrint('当前目录文件列表:');
    for (var file in children) {
      debugPrint('- ${file.title} (类型: ${file.type})');
    }

    // 字幕文件名应该是音频文件名加上.vtt
    final subtitleFileName = '$audioFileName.vtt';
    debugPrint('查找字幕文件: $subtitleFileName');

    // 先在当前目录查找
    try {
      final subtitleFile = children.firstWhere(
        (file) => file.title == subtitleFileName,
      );
      debugPrint('找到字幕文件: ${subtitleFile.title}, URL: ${subtitleFile.mediaDownloadUrl}');
      return subtitleFile;
    } catch (e) {
      // 如果当前目录没找到，递归查找子目录
      for (var child in children) {
        if (child.children != null) {
          debugPrint('进入子目录继续查找...');
          final result = _findSubtitleInDirectory(child.children!, audioFileName);
          if (result != null) {
            return result;
          }
        }
      }
    }

    debugPrint('在当前目录及子目录中未找到字幕文件');
    return null;
  }

  // 便捷方法：获取可播放文件列表
  List<Child> getPlayableFiles() {
    if (files.children == null) return [];
    return files.children!.where((file) => 
      file.mediaDownloadUrl != null && 
      file.type?.toLowerCase() != 'vtt'
    ).toList();
  }

  // 工具方法：获取文件名（不含扩展名）
  String? _getBaseName(String? filename) {
    if (filename == null) return null;
    return filename.replaceAll(RegExp(r'\.[^.]+$'), '');
  }
} 