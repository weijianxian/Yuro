import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:asmrapp/utils/logger.dart';
import './i_audio_player_service.dart';
import './models/audio_track_info.dart';
import './models/playback_context.dart';
import './notification/audio_notification_service.dart';
import './models/play_mode.dart';
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/core/audio/storage/i_playback_state_repository.dart';
import 'package:asmrapp/data/models/playback/playback_state.dart';
import './utils/track_info_creator.dart';
import './utils/playlist_builder.dart';
import './utils/audio_error_handler.dart';
import './state/playback_state_manager.dart';


class AudioPlayerService implements IAudioPlayerService {
  late final AudioPlayer _player;
  late final AudioNotificationService _notificationService;
  late final ConcatenatingAudioSource _playlist;
  late final PlaybackStateManager _stateManager;
  final _contextController = StreamController<PlaybackContext?>.broadcast();
  final _stateRepository = GetIt.I<IPlaybackStateRepository>();

  AudioPlayerService._internal() {
    _init();
  }

  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  Future<void> _init() async {
    try {
      _player = AudioPlayer();
      _notificationService = AudioNotificationService(_player);
      _playlist = ConcatenatingAudioSource(children: []);

      _stateManager = PlaybackStateManager(
        player: _player,
        notificationService: _notificationService,
        stateRepository: _stateRepository,
        contextController: _contextController,
      );

      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _notificationService.init();

      await restorePlaybackState();
      
      // 初始化状态监听
      _stateManager.initStateListeners();
      _initPlaybackCompletionListener();
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.init,
        '音频播放器初始化',
        e,
        stack,
      );
      AudioErrorHandler.throwError(
        AudioErrorType.init,
        '音频播放器初始化',
        e,
      );
    }
  }

  void _initPlaybackCompletionListener() {
    _stateManager.playbackCompletionStream.listen((playMode) {
      switch (playMode) {
        case PlayMode.single:
          _handleSingleModeCompletion();
          break;
        case PlayMode.loop:
          _handleLoopModeCompletion();
          break;
        case PlayMode.sequence:
          _handleSequenceModeCompletion();
          break;
      }
    });
  }

  Future<void> _handleSingleModeCompletion() async {
    await _player.seek(Duration.zero);
    await _player.play();
  }

  Future<void> _handleLoopModeCompletion() async {
    if (_player.hasNext) {
      await next();
    } else {
      await _player.seek(Duration.zero, index: 0);
      await _player.play();
    }
  }

  Future<void> _handleSequenceModeCompletion() async {
    if (_player.hasNext) {
      await next();
    }
  }

  @override
  Future<void> pause() async {
    _player.pause();
  }

  @override
  Future<void> resume() async {
    _player.play();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _stateManager.clearState();
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
  AudioTrackInfo? get currentTrack => _stateManager.currentTrack;

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> previous() async {
    try {
      if (_stateManager.currentContext == null) {
        AudioErrorHandler.handleError(
          AudioErrorType.context,
          '切换上一曲',
          '播放上下文为空'
        );
        return;
      }

      if (_player.hasPrevious) {
        final previousFile = _stateManager.currentContext!.getPreviousFile();
        if (previousFile != null) {
          _stateManager.updateTrackAndContext(
            previousFile,
            _stateManager.currentContext!.work,
          );
          await _player.seekToPrevious();
        }
      } else {
        AudioErrorHandler.handleError(
          AudioErrorType.playback,
          '切换上一曲',
          '已经是第一首'
        );
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

  @override
  Future<void> next() async {
    try {
      if (_stateManager.currentContext == null) {
        AppLogger.debug('无法切换下一曲：播放上下文为空');
        return;
      }

      // 使用 just_audio 的播放列表控制
      if (_player.hasNext) {
        // 更新 context
        final nextFile = _stateManager.currentContext!.getNextFile();
        if (nextFile != null) {
          _stateManager.updateContext(_stateManager.currentContext!.copyWithFile(nextFile));
          
          // 更新音轨信息
          final trackInfo = TrackInfoCreator.createFromFile(
            nextFile,
            _stateManager.currentContext!.work,
          );
          _stateManager.updateTrackInfo(trackInfo);

          // 切换到下一曲
          await _player.seekToNext();
        }
      } else {
        AppLogger.debug('无法切换下一曲：已经是最后一首');
      }
    } catch (e) {
      AppLogger.error('切换下一曲失败', e);
    }
  }

  @override
  PlaybackContext? get currentContext => _stateManager.currentContext;

  @override
  Future<void> playWithContext(PlaybackContext context) async {
    try {
      AppLogger.debug('开始处理播放上下文');
      AppLogger.debug('当前文件标题: ${context.currentFile.title}');
      AppLogger.debug('播放列表数量: ${context.playlist.length}');
      
      _stateManager.updateContext(context);

      // 设置播放列表
      try {
        await PlaylistBuilder.setPlaylistSource(
          player: _player,
          playlist: _playlist,
          files: context.playlist,
          initialIndex: context.currentIndex,
          initialPosition: Duration.zero,
        );
      } catch (e, stack) {
        AudioErrorHandler.handleError(
          AudioErrorType.playlist,
          '设置播放列表',
          e,
          stack,
        );
        AudioErrorHandler.throwError(
          AudioErrorType.playlist,
          '设置播放列表',
          e,
        );
      }

      // 开始播放
      await _player.play();
      AppLogger.debug('开始播放成功');
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.context,
        '处理播放上下文',
        e,
        stack,
      );
      _stateManager.clearState();
      rethrow;
    }
  }

  @override
  Stream<PlaybackContext?> get contextStream => _stateManager.contextStream;

  @override
  Future<void> savePlaybackState() async {
    if (_stateManager.currentContext == null) return;

    try {
      final state = PlaybackState(
        work: _stateManager.currentContext!.work,
        files: _stateManager.currentContext!.files,
        currentFile: _stateManager.currentContext!.currentFile,
        playlist: _stateManager.currentContext!.playlist,
        currentIndex: _stateManager.currentContext!.currentIndex,
        playMode: _stateManager.currentContext!.playMode,
        position: (await _player.position).inMilliseconds,
        timestamp: DateTime.now().toIso8601String(),
      );
      
      await _stateRepository.saveState(state);
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.state,
        '保存播放状态',
        e,
        stack,
      );
    }
  }

  @override
  Future<void> restorePlaybackState() async {
    try {
      final state = await _stateRepository.loadState();
      if (state == null) return;

      _stateManager.updateContext(PlaybackContext(
        work: state.work,
        files: state.files,
        currentFile: state.currentFile,
        playMode: state.playMode,
      ));

      try {
        await PlaylistBuilder.setPlaylistSource(
          player: _player,
          playlist: _playlist,
          files: _stateManager.currentContext!.playlist,
          initialIndex: state.currentIndex,
          initialPosition: Duration(milliseconds: state.position),
        );
      } catch (e, stack) {
        AudioErrorHandler.handleError(
          AudioErrorType.playlist,
          '恢复播放列表',
          e,
          stack,
        );
        return;
      }

      final trackInfo = TrackInfoCreator.createFromFile(
        state.currentFile,
        state.work,
      );
      _stateManager.updateTrackInfo(trackInfo);
      
      await _player.play();
      await _player.stop();
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.state,
        '恢复播放状态',
        e,
        stack,
      );
    }
  }
}
