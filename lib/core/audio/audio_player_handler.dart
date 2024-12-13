import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:asmrapp/utils/logger.dart';

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player;

  AudioPlayerHandler(this._player) {
    AppLogger.debug('AudioPlayerHandler 初始化');
    _player.playbackEventStream.listen(_broadcastState);
    _player.playerStateStream.listen((state) {
      // AppLogger.debug(
      //     '播放器状态变化: playing=${state.playing}, state=${state.processingState}');
      _broadcastState(_player.playbackEvent);
    });
  }

  void _broadcastState(PlaybackEvent event) {
    // AppLogger.debug(
    //     '广播播放状态: position=${_player.position}, buffered=${_player.bufferedPosition}');

    final state = PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
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
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: 0,
    );

    // AppLogger.debug(
        // '更新播放状态: playing=${_player.playing}, state=${_player.processingState}');
    playbackState.add(state);
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
}
