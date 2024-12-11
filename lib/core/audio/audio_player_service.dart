import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:asmrapp/utils/logger.dart';
import './i_audio_player_service.dart';
import './models/audio_track_info.dart';
import './notification/audio_notification_service.dart';

class AudioPlayerService implements IAudioPlayerService {
  late final AudioPlayer _player;
  late final AudioNotificationService _notificationService;
  AudioTrackInfo? _currentTrack;
  
  AudioPlayerService._internal() {
    _init();
  }
  
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  
  Future<void> _init() async {
    _player = AudioPlayer();
    _notificationService = AudioNotificationService(_player);
    
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
        await _player.setUrl(url);
        
        // 等待获取到音频时长后再更新通知栏
        final duration = await _player.duration;
        final updatedTrackInfo = AudioTrackInfo(
          title: trackInfo.title,
          artist: trackInfo.artist,
          coverUrl: trackInfo.coverUrl,
          url: trackInfo.url,
          duration: duration,  // 使用实际获取到的时长
        );
        _notificationService.updateMetadata(updatedTrackInfo);
      }
      
      await _player.play();
    } catch (e) {
      _currentTrack = null;
      AppLogger.error('播放失败', e);
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
}