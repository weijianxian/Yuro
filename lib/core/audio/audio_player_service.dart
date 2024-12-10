import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:asmrapp/utils/logger.dart';
import './i_audio_player_service.dart';

class AudioPlayerService implements IAudioPlayerService {
  AudioPlayerService._internal() {
    _init();
  }
  
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  
  late final AudioPlayer _player;
  
  Future<void> _init() async {
    _player = AudioPlayer();
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      _player.playerStateStream.listen((state) {
        AppLogger.debug('播放状态变化: $state');
      });
    } catch (e) {
      AppLogger.error('音频播放器初始化失败', e);
    }
  }

  @override
  Future<void> play(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
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
  }
  
  @override
  Future<void> dispose() async {
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
}