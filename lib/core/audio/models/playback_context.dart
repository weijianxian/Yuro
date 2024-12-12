import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:flutter/foundation.dart';

class PlaybackContext {
  final Work work;
  final Files files;
  final Child currentFile;

  const PlaybackContext({
    required this.work,
    required this.files,
    required this.currentFile,
  });

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