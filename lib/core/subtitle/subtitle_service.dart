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
  final _currentSubtitleWithStateController = StreamController<SubtitleWithState?>.broadcast();
  SubtitleWithState? _currentSubtitleWithState;
  
  @override
  Stream<SubtitleList?> get subtitleStream => _subtitleController.stream;
  
  @override
  Stream<Subtitle?> get currentSubtitleStream => _currentSubtitleController.stream;
  
  @override
  Subtitle? get currentSubtitle {
    if (_subtitleList == null) return null;
    return _currentSubtitle;
  }
  
  @override
  Future<void> loadSubtitle(String url) async {
    try {
      clearSubtitle();
      
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
      clearSubtitle();
      rethrow;
    }
  }
  
  @override
  void updatePosition(Duration position) {
    if (_subtitleList != null) {
      final newSubtitleWithState = _subtitleList!.getCurrentSubtitle(position);
      if (newSubtitleWithState?.subtitle != _currentSubtitleWithState?.subtitle) {
        _currentSubtitleWithState = newSubtitleWithState;
        _currentSubtitle = newSubtitleWithState?.subtitle;
        AppLogger.debug('字幕更新: ${_currentSubtitle?.text ?? '无字幕'} (${newSubtitleWithState?.state})');
        _currentSubtitleWithStateController.add(newSubtitleWithState);
        _currentSubtitleController.add(_currentSubtitle);
      }
    }
  }

  @override
  void dispose() {
    _subtitleController.close();
    _currentSubtitleController.close();
    _currentSubtitleWithStateController.close();
  }

  @override
  SubtitleList? get subtitleList => _subtitleList;

  @override
  void clearSubtitle() {
    _subtitleList = null;
    _currentSubtitle = null;
    _currentSubtitleWithState = null;
    _subtitleController.add(null);
    _currentSubtitleController.add(null);
    _currentSubtitleWithStateController.add(null);
    AppLogger.debug('字幕已清除');
  }

  @override
  Stream<SubtitleWithState?> get currentSubtitleWithStateStream => 
      _currentSubtitleWithStateController.stream;
  
  @override
  SubtitleWithState? get currentSubtitleWithState => _currentSubtitleWithState;
} 