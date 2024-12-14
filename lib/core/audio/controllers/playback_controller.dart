import 'package:just_audio/just_audio.dart';
import '../models/playback_context.dart';
import '../state/playback_state_manager.dart';
import '../utils/playlist_builder.dart';
import '../utils/audio_error_handler.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/data/models/works/work.dart';

class PlaybackController {
  final AudioPlayer _player;
  final PlaybackStateManager _stateManager;
  final ConcatenatingAudioSource _playlist;

  PlaybackController({
    required AudioPlayer player,
    required PlaybackStateManager stateManager,
    required ConcatenatingAudioSource playlist,
  }) : _player = player,
       _stateManager = stateManager,
       _playlist = playlist;

  // 基础播放控制
  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position, {int? index}) => _player.seek(position, index: index);
  
  // 播放列表控制
  Future<void> next() async {
    try {
      if (_stateManager.currentContext == null) return;

      if (_player.hasNext) {
        final nextFile = _stateManager.currentContext!.getNextFile();
        if (nextFile != null) {
          _updateTrackAndContext(
            nextFile, 
            _stateManager.currentContext!.work
          );
          await _player.seekToNext();
        }
      }
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.playback,
        '切换下一曲',
        e,
        stack,
      );
    }
  }

  Future<void> previous() async {
    try {
      if (_stateManager.currentContext == null) return;

      if (_player.hasPrevious) {
        final previousFile = _stateManager.currentContext!.getPreviousFile();
        if (previousFile != null) {
          _updateTrackAndContext(
            previousFile,
            _stateManager.currentContext!.work
          );
          await _player.seekToPrevious();
        }
      }
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.playback,
        '切换上一曲',
        e,
        stack,
      );
    }
  }

  // 播放上下文设置
  Future<void> setPlaybackContext(PlaybackContext context) async {
    try {
      _stateManager.updateContext(context);
      
      await PlaylistBuilder.setPlaylistSource(
        player: _player,
        playlist: _playlist,
        files: context.playlist,
        initialIndex: context.currentIndex,
        initialPosition: Duration.zero,
      );

      _updateTrackAndContext(context.currentFile, context.work);
      await play();
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.context,
        '设置播放上下文',
        e,
        stack,
      );
    }
  }

  // 私有辅助方法
  void _updateTrackAndContext(Child file, Work work) {
    _stateManager.updateTrackAndContext(file, work);
  }
} 