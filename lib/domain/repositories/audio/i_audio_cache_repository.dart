import 'package:just_audio/just_audio.dart';

abstract class IAudioCacheRepository {
  /// 获取音频源，如果不存在则下载并缓存
  Future<AudioSource> getAudioSource(String url);

  /// 获取缓存状态
  Future<bool> isCached(String url);

  /// 获取缓存大小
  Future<int> getCacheSize();

  /// 清理缓存
  Future<void> clearCache();
} 