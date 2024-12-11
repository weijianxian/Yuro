import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:rxdart/rxdart.dart';
import '../models/audio_track_info.dart';
import '../audio_player_handler.dart';

class AudioNotificationService {
  final AudioPlayer _player;
  AudioHandler? _audioHandler;
  final _playbackState = BehaviorSubject<PlaybackState>();
  final _mediaItem = BehaviorSubject<MediaItem?>();

  AudioNotificationService(this._player);

  Future<void> init() async {
    try {
      _audioHandler = await AudioService.init(
        builder: () => AudioPlayerHandler(_player),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.asmrapp.audio',
          androidNotificationChannelName: 'ASMR One 播放器',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );

      _setupPlayerStateListener();
      AppLogger.debug('通知栏服务初始化成功');
    } catch (e) {
      AppLogger.error('通知栏服务初始化失败', e);
      rethrow;
    }
  }

  void _setupPlayerStateListener() {
    _player.playerStateStream.listen((state) {
      final playbackState = PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          state.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[state.processingState]!,
        playing: state.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: 0,
      );
      
      _playbackState.add(playbackState);
      if (_audioHandler != null) {
        (_audioHandler as BaseAudioHandler).playbackState.add(playbackState);
      }
    });
  }

  void updateMetadata(AudioTrackInfo trackInfo) {
    final mediaItem = MediaItem(
      id: trackInfo.url,
      title: trackInfo.title,
      artist: trackInfo.artist,
      artUri: Uri.parse(trackInfo.coverUrl),
    );
    
    _mediaItem.add(mediaItem);
    if (_audioHandler != null) {
      (_audioHandler as BaseAudioHandler).mediaItem.add(mediaItem);
    }
  }

  Future<void> dispose() async {
    await _audioHandler?.stop();
    await _playbackState.close();
    await _mediaItem.close();
  }
} 