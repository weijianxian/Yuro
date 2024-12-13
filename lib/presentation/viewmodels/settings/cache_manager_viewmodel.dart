import 'package:flutter/foundation.dart';
import 'package:asmrapp/core/audio/cache/audio_cache_manager.dart';
import 'package:asmrapp/utils/logger.dart';

class CacheManagerViewModel extends ChangeNotifier {
  bool _isLoading = false;
  int _cacheSize = 0;
  String? _error;

  bool get isLoading => _isLoading;
  int get cacheSize => _cacheSize;
  String? get error => _error;

  // 格式化缓存大小显示
  String get cacheSizeFormatted {
    if (_cacheSize < 1024) return '${_cacheSize}B';
    if (_cacheSize < 1024 * 1024) return '${(_cacheSize / 1024).toStringAsFixed(2)}KB';
    return '${(_cacheSize / (1024 * 1024)).toStringAsFixed(2)}MB';
  }

  // 加载缓存大小
  Future<void> loadCacheSize() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _cacheSize = await AudioCacheManager.getCacheSize();
      _error = null;
    } catch (e) {
      AppLogger.error('加载缓存大小失败', e);
      _error = '加载失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 清理缓存
  Future<void> clearCache() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await AudioCacheManager.cleanCache();
      await loadCacheSize(); // 重新加载缓存大小
      _error = null;
    } catch (e) {
      AppLogger.error('清理缓存失败', e);
      _error = '清理失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 