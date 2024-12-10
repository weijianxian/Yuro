import 'package:flutter/foundation.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:asmrapp/utils/logger.dart';

class DetailViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Work work;
  
  Files? _files;
  bool _isLoading = false;
  String? _error;

  DetailViewModel({required this.work});

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
} 