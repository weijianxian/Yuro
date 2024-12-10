import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:asmrapp/core/audio/i_audio_player_service.dart';
import 'package:asmrapp/utils/logger.dart';

class DetailViewModel extends ChangeNotifier {
  late final ApiService _apiService;
  late final IAudioPlayerService _audioService;
  final Work work;
  
  Files? _files;
  bool _isLoading = false;
  String? _error;

  DetailViewModel({
    required this.work,
  }) {
    _audioService = GetIt.I<IAudioPlayerService>();
    _apiService = GetIt.I<ApiService>();
  }

  Files? get files => _files;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFiles() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('开始加载作品文件: ${work.id}');
      _files = await _apiService.getWorkFiles(work.id.toString());
      AppLogger.info('文件加载成功: ${work.id}');
    } catch (e) {
      AppLogger.error('加载文件失败', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playFile(Child file, BuildContext context) async {
    if (file.mediaDownloadUrl == null) {
      throw Exception('无法播放：文件URL不存在');
    }
    
    try {
      await _audioService.play(file.mediaDownloadUrl!);
    } catch (e) {
      AppLogger.error('播放失败', e);
      rethrow;
    }
  }
} 