import 'package:asmrapp/core/audio/events/playback_event_hub.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:asmrapp/utils/logger.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player;
  final PlaybackEventHub _eventHub;

  AudioPlayerHandler(this._player, this._eventHub) {
    AppLogger.debug('AudioPlayerHandler 初始化');
    
    // 监听轨道变更事件来更新队列
    _eventHub.trackChange.listen((event) {
      // 更新 MediaItem
      final mediaItem = MediaItem(
        id: event.track.url,
        title: event.track.title,
        artist: event.track.artist,
        artUri: event.track.coverUrl.isNotEmpty ? Uri.tryParse(event.track.coverUrl) : null,
        duration: event.track.duration,
      );
      this.mediaItem.add(mediaItem);
      AppLogger.debug('MediaSession: 更新 MediaItem - ${event.track.title}, duration: ${event.track.duration}');
    });
    
    // 改为监听 EventHub
    _eventHub.playbackState.listen((event) {
      final state = PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          event.state.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToPrevious,
          MediaAction.skipToNext,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[event.state.processingState]!,
        playing: event.state.playing,
        updatePosition: event.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex ?? 0,
        // 确保包含音频总时长
        duration: event.duration,
      );
      playbackState.add(state);
    });
  }

  @override
  Future<void> play() async {
    AppLogger.debug('AudioHandler: 播放命令');
    _player.play();
  }

  @override
  Future<void> pause() async {
    AppLogger.debug('AudioHandler: 暂停命令');
    _player.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    AppLogger.debug('AudioHandler: 跳转命令 position=$position');
    await _player.seek(position);
  }

  @override
  Future<void> stop() async {
    AppLogger.debug('AudioHandler: 停止命令');
    await _player.stop();
  }

  @override
  Future<void> skipToNext() async {
    AppLogger.debug('AudioHandler: 下一曲命令');
    // 通过 EventHub 发送下一曲请求，让 PlaybackController 处理
    _eventHub.emit(SkipToNextEvent());
  }

  @override
  Future<void> skipToPrevious() async {
    AppLogger.debug('AudioHandler: 上一曲命令');
    // 通过 EventHub 发送上一曲请求，让 PlaybackController 处理
    _eventHub.emit(SkipToPreviousEvent());
  }
}
