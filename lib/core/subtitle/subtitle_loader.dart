import 'package:flutter/foundation.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/core/audio/models/file_path.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'package:dio/dio.dart';
import 'package:asmrapp/utils/logger.dart';

class SubtitleLoader {
  final _dio = Dio();

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

  // 新增: 加载字幕内容
  Future<SubtitleList?> loadSubtitleContent(String url) async {
    try {
      AppLogger.debug('正在下载字幕文件: $url');
      final response = await _dio.get(url);
      AppLogger.debug('字幕文件下载状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final content = response.data as String;
        AppLogger.debug('字幕文件内容预览: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
        
        final subtitleList = SubtitleList.parse(content);
        AppLogger.debug('字幕解析完成，字幕数量: ${subtitleList.subtitles.length}');
        
        return subtitleList;
      } else {
        throw Exception('字幕下载失败: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.debug('字幕加载失败: $e');
      rethrow;
    }
  }
} 