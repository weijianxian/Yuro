import 'package:flutter/foundation.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/core/audio/models/file_path.dart';

class SubtitleLoader {
  // 查找字幕文件
  Child? findSubtitleFile(Child audioFile, Files files) {
    if (files.children == null || audioFile.title == null) {
      debugPrint('无法查找字幕文件: ${files.children == null ? '文件列表为空' : '当前文件名为空'}');
      return null;
    }

    debugPrint('开始查找字幕文件...');
    
    // 使用 FilePath 获取同级文件
    final siblings = FilePath.getSiblings(audioFile, files);
    
    // 构造字幕文件名 (不需要去掉音频文件的扩展名，直接加上.vtt)
    final audioBaseName = audioFile.title;
    final subtitleFileName = '$audioBaseName.vtt';
    debugPrint('查找字幕文件: $subtitleFileName');
    
    // 在同级文件中查找字幕
    try {
      final subtitleFile = siblings.firstWhere(
        (file) => file.title == subtitleFileName
      );
      debugPrint('找到字幕文件: ${subtitleFile.title}, URL: ${subtitleFile.mediaDownloadUrl}');
      return subtitleFile;
    } catch (e) {
      debugPrint('在当前目录中未找到字幕文件');
      return null;
    }
  }
} 