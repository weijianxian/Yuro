import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:logger/logger.dart';
import './i_audio_player_service.dart';
import './models/audio_track_info.dart';
import './notification/audio_notification_service.dart';
import '../../data/repositories/audio/audio_cache_repository.dart';

class AudioPlayerService implements IAudioPlayerService {
  late final AudioPlayer _player;
  late final AudioNotificationService _notificationService;
  late final AudioCacheRepository _cacheRepository;
  AudioTrackInfo? _currentTrack;

  AudioPlayerService._internal() {
    _init();
  }

  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  Future<void> _init() async {
    _player = AudioPlayer();
    _notificationService = AudioNotificationService(_player);
    _cacheRepository = AudioCacheRepository();

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _notificationService.init();

      _player.playerStateStream.listen((state) {
        AppLogger.debug('播放状态变化: $state');
      });
    } catch (e) {
      AppLogger.error('音频播放器初始化失败', e);
    }
  }

  @override
  Future<void> play(String url, {AudioTrackInfo? trackInfo}) async {
    try {
      if (trackInfo != null) {
        _currentTrack = trackInfo;

        AppLogger.debug('准备播放URL: $url');

        // 使用缓存音频源
        final audioSource = await _cacheRepository.getAudioSource(url);
        AppLogger.debug('创建音频源成功: $url');

        try {
          await _player.stop(); // 先停止当前播放
          AppLogger.debug('停止当前播放');

          await _player.setAudioSource(audioSource);
          AppLogger.debug('设置音频源成功');
        } catch (e, stack) {
          AppLogger.error('设置音频源失败', e, stack);
          throw Exception('设置音频源失败: $e');
        }

        // 等待获取到音频时长后再更新通知栏
        try {
          final duration = _player.duration;
          AppLogger.debug('获取音频时长成功: $duration');

          final updatedTrackInfo = AudioTrackInfo(
            title: trackInfo.title,
            artist: trackInfo.artist,
            coverUrl: trackInfo.coverUrl,
            url: trackInfo.url,
            duration: duration,
          );
          _notificationService.updateMetadata(updatedTrackInfo);
        } catch (e, stack) {
          AppLogger.error('获取音频时长失败', e, stack);
          // 不抛出异常，继续尝试播放
        }
      }

      try {
        await _player.play();
        AppLogger.debug('开始播放成功');
      } catch (e, stack) {
        AppLogger.error('开始播放失败', e, stack);
        throw Exception('开始播放失败: $e');
      }
    } catch (e, stack) {
      _currentTrack = null;
      AppLogger.error('播放失败', e, stack);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> resume() async {
    await _player.play();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _currentTrack = null;
  }

  @override
  Future<void> dispose() async {
    await _notificationService.dispose();
    await _player.dispose();
  }

  @override
  Stream<PlayerState> get playerState => _player.playerStateStream;

  @override
  Stream<Duration?> get position => _player.positionStream;

  @override
  Stream<Duration?> get bufferedPosition => _player.bufferedPositionStream;

  @override
  Stream<Duration?> get duration => _player.durationStream;

  @override
  AudioTrackInfo? get currentTrack => _currentTrack;

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      AppLogger.debug('Seek failed: $e');
    }
  }

  @override
  Future<void> previous() async {
    // 由于目前没有播放列表管理，暂时只实现重新播放当前曲目
    try {
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      AppLogger.debug('Previous failed: $e');
    }
  }

  @override
  Future<void> next() async {
    // 由于目前没有播放列表管理，暂时只实现重新播放当前曲目
    try {
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      AppLogger.debug('Next failed: $e');
    }
  }
}
