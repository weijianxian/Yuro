import 'package:just_audio/just_audio.dart';
import 'package:asmrapp/utils/logger.dart';
import '../../../domain/repositories/audio/i_audio_cache_repository.dart';

class AudioCacheRepository implements IAudioCacheRepository {
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
} 