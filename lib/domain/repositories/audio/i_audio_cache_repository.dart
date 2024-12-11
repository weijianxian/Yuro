import 'package:just_audio/just_audio.dart';

abstract class IAudioCacheRepository {
  /// 获取音频源
  Future<AudioSource> getAudioSource(String url);
} 