import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:asmrapp/utils/logger.dart';

/// 音频缓存管理器
/// 负责管理音频文件的缓存,对外隐藏具体的缓存实现
class AudioCacheManager {
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxFileCacheSize = 10 * 1024 * 1024; // 10MB 
  static const Duration _cacheExpiration = Duration(days: 30);

  /// 创建音频源
  /// 内部处理缓存逻辑,对外只返回 AudioSource
  static Future<AudioSource> createAudioSource(String url) async {
    try {
      final cacheFile = await _getCacheFile(url);
      
      // 检查缓存文件是否存在且有效
      if (await _isCacheValid(cacheFile)) {
        AppLogger.debug('使用缓存文件: ${cacheFile.path}');
        return _createCachingSource(url, cacheFile);
      }

      // 如果缓存无效,创建新的缓存源
      AppLogger.debug('创建新的缓存源: $url');
      return _createCachingSource(url, cacheFile);
      
    } catch (e) {
      // 任何错误都降级使用非缓存源
      AppLogger.error('创建缓存音频源失败,使用非缓存源', e);
      return ProgressiveAudioSource(Uri.parse(url));
    }
  }

  /// 清理过期和超量的缓存
  static Future<void> cleanCache() async {
    try {
      final cacheDir = await _getCacheDir();
      final files = await cacheDir.list().toList();
      
      // 按修改时间排序
      files.sort((a, b) {
        return a.statSync().modified.compareTo(b.statSync().modified);
      });

      var totalSize = 0;
      for (var file in files) {
        if (file is File) {
          final stat = await file.stat();
          
          // 检查是否过期
          if (DateTime.now().difference(stat.modified) > _cacheExpiration) {
            await file.delete();
            continue;
          }

          totalSize += stat.size;
          
          // 如果总大小超过限制,删除最旧的文件
          if (totalSize > _maxCacheSize) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      AppLogger.error('清理缓存失败', e);
    }
  }

  /// 获取缓存大小
  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDir();
      final files = await cacheDir.list().toList();
      
      var totalSize = 0;
      for (var file in files) {
        if (file is File) {
          totalSize += (await file.stat()).size;
        }
      }
      return totalSize;
    } catch (e) {
      AppLogger.error('获取缓存大小失败', e);
      return 0;
    }
  }

  // 私有方法

  /// 创建缓存音频源
  static AudioSource _createCachingSource(String url, File cacheFile) {
    return LockCachingAudioSource(
      Uri.parse(url),
      cacheFile: cacheFile
    );
  }

  /// 检查缓存是否有效
  static Future<bool> _isCacheValid(File cacheFile) async {
    if (!await cacheFile.exists()) return false;

    try {
      final stat = await cacheFile.stat();
      
      // 检查文件大小
      if (stat.size > _maxFileCacheSize) {
        await cacheFile.delete();
        return false;
      }

      // 检查是否过期
      if (DateTime.now().difference(stat.modified) > _cacheExpiration) {
        await cacheFile.delete();
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('检查缓存有效性失败', e);
      return false;
    }
  }

  /// 获取缓存文件
  static Future<File> _getCacheFile(String url) async {
    final cacheDir = await _getCacheDir();
    final fileName = _generateFileName(url);
    return File('${cacheDir.path}/$fileName');
  }

  /// 生成缓存文件名
  static String _generateFileName(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// 获取缓存目录
  static Future<Directory> _getCacheDir() async {
    final cacheDir = await getTemporaryDirectory();
    final audioCacheDir = Directory('${cacheDir.path}/audio_cache');
    if (!await audioCacheDir.exists()) {
      await audioCacheDir.create(recursive: true);
    }
    return audioCacheDir;
  }
}