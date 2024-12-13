import 'dart:async';
import 'package:asmrapp/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'package:asmrapp/core/subtitle/i_subtitle_service.dart';


class SubtitleService implements ISubtitleService {
  final _dio = Dio();
  SubtitleList? _subtitleList;
  Subtitle? _currentSubtitle;
  final _subtitleController = StreamController<SubtitleList?>.broadcast();
  final _currentSubtitleController = StreamController<Subtitle?>.broadcast();
  
  @override
  Stream<SubtitleList?> get subtitleStream => _subtitleController.stream;
  
  @override
  Stream<Subtitle?> get currentSubtitleStream => _currentSubtitleController.stream;
  
  @override
  Subtitle? get currentSubtitle => _currentSubtitle;
  
  @override
  Future<void> loadSubtitle(String url) async {
    try {
      AppLogger.debug('正在下载字幕文件: $url');
      final response = await _dio.get(url);
      AppLogger.debug('字幕文件下载状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final content = response.data as String;
        AppLogger.debug('字幕文件内容预览: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
        
        _subtitleList = SubtitleList.parse(content);
        AppLogger.debug('字幕解析完成，字幕数量: ${_subtitleList?.subtitles.length ?? 0}');
        
        _subtitleController.add(_subtitleList);
      } else {
        throw Exception('字幕下载失败: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.debug('字幕加载失败: $e');
      _subtitleList = null;
      _subtitleController.add(null);
      rethrow;
    }
  }
  
  @override
  void updatePosition(Duration position) {
    if (_subtitleList != null) {
      final newSubtitle = _subtitleList!.getCurrentSubtitle(position);
      if (newSubtitle != _currentSubtitle) {
        _currentSubtitle = newSubtitle;
        AppLogger.debug('字幕更新: ${newSubtitle?.text ?? '无字幕'}');
        _currentSubtitleController.add(newSubtitle);
      }
    }
  }

  @override
  void dispose() {
    _subtitleController.close();
    _currentSubtitleController.close();
  }

  @override
  SubtitleList? get subtitleList => _subtitleList;

  @override
  void clearSubtitle() {
    _subtitleList = null;
    _currentSubtitle = null;
    _subtitleController.add(null);
    _currentSubtitleController.add(null);
    AppLogger.debug('字幕已清除');
  }
} 