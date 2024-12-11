import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:asmrapp/utils/logger.dart';
import '../../../domain/repositories/audio/i_audio_cache_repository.dart';

class AudioCacheRepository implements IAudioCacheRepository {
  static const String _cacheDirName = 'audio_cache';
  late final Directory _cacheDir;
  
  AudioCacheRepository() {
    _init();
  }

  Future<void> _init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/$_cacheDirName');
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
    AppLogger.debug('缓存目录初始化完成: ${_cacheDir.path}');
  }

  String _getCacheKey(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  @override
  Future<AudioSource> getAudioSource(String url) async {
    try {
      AppLogger.debug('准备创建音频源: $url');
      
      // 检查URL是否有效
      final uri = Uri.parse(url);
      if (!uri.hasScheme) {
        throw Exception('无效的URL: $url');
      }
      
      // 使用 ProgressiveAudioSource 来处理缓冲
      return ProgressiveAudioSource(uri);
      
    } catch (e, stack) {
      AppLogger.error('创建音频源失败', e, stack);
      rethrow;
    }
  }

  @override
  Future<bool> isCached(String url) async {
    return false; // 暂时不实现缓存检查
  }

  @override
  Future<int> getCacheSize() async {
    return 0; // 暂时不实现缓存大小计算
  }

  @override
  Future<void> clearCache() async {
    // 暂时不实现缓存清理
  }
} 