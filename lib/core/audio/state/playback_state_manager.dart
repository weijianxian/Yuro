import 'dart:async';
import 'package:asmrapp/core/audio/models/play_mode.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audio_track_info.dart';
import '../models/playback_context.dart';
import '../notification/audio_notification_service.dart';
import '../utils/audio_error_handler.dart';
import '../utils/track_info_creator.dart';
import 'package:asmrapp/data/models/playback/playback_state.dart';
import '../storage/i_playback_state_repository.dart';
import '../events/playback_event.dart';
import '../events/playback_event_hub.dart';

class PlaybackStateManager {
  final AudioPlayer _player;
  final AudioNotificationService _notificationService;
  final IPlaybackStateRepository _stateRepository;
  final PlaybackEventHub _eventHub;

  AudioTrackInfo? _currentTrack;
  PlaybackContext? _currentContext;

  PlaybackStateManager({
    required AudioPlayer player,
    required AudioNotificationService notificationService,
    required IPlaybackStateRepository stateRepository,
    required PlaybackEventHub eventHub,
  }) : _player = player,
       _notificationService = notificationService,
       _stateRepository = stateRepository,
       _eventHub = eventHub;

  // 初始化状态监听
  void initStateListeners() {
    // 播放状态变化监听
    _player.playerStateStream.listen((state) async {
      final position = _player.position;
      final duration = _player.duration;
      
      _eventHub.emit(PlaybackStateEvent(state, position, duration));

      if (state.processingState == ProcessingState.completed) {
        _onPlaybackCompleted();
      }
      saveState();
    });

    // 播放进度监听
    _player.positionStream.listen((position) {
      _eventHub.emit(PlaybackProgressEvent(
        position,
        _player.bufferedPosition
      ));
    });
  }

  // 状态更新方法
  void updateContext(PlaybackContext? context) {
    _currentContext = context;
    _contextController.add(context);
    if (context != null) {
      _eventHub.emit(PlaybackContextEvent(context));
    }
  }

  void updateTrackInfo(AudioTrackInfo track) {
    _currentTrack = track;
    _notificationService.updateMetadata(track);
  }

  void updateTrackAndContext(Child file, Work work) {
    if (_currentContext != null) {
      final newContext = _currentContext!.copyWithFile(file);
      updateContext(newContext);
    }
    
    final trackInfo = TrackInfoCreator.createFromFile(file, work);
    updateTrackInfo(trackInfo);
    
    _eventHub.emit(TrackChangeEvent(trackInfo, file, work));
  }

  void _onPlaybackCompleted() {
    if (_currentContext == null) return;
    _eventHub.emit(PlaybackCompletedEvent(_currentContext!));
  }

  // 状态访问
  AudioTrackInfo? get currentTrack => _currentTrack;
  PlaybackContext? get currentContext => _currentContext;

  void clearState() {
    _currentTrack = null;
    _currentContext = null;
    updateContext(null);
  }

  // 状态持久化
  Future<void> saveState() async {
    if (_currentContext == null) return;

    try {
      final state = PlaybackState(
        work: _currentContext!.work,
        files: _currentContext!.files,
        currentFile: _currentContext!.currentFile,
        playlist: _currentContext!.playlist,
        currentIndex: _currentContext!.currentIndex,
        playMode: _currentContext!.playMode,
        position: (_player.position).inMilliseconds,
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

  Future<PlaybackState?> loadState() async {
    try {
      return await _stateRepository.loadState();
    } catch (e, stack) {
      AudioErrorHandler.handleError(
        AudioErrorType.state,
        '加载播放状态',
        e,
        stack,
      );
      return null;
    }
  }

  // 播放完成事件流
  final _playbackCompletionController = StreamController<PlayMode>.broadcast();
  Stream<PlayMode> get playbackCompletionStream => _playbackCompletionController.stream;

  // 添加上下文流控制器
  final _contextController = StreamController<PlaybackContext?>.broadcast();
  
  // 添加上下文流 getter
  Stream<PlaybackContext?> get contextStream => _contextController.stream;

  void dispose() {
    _playbackCompletionController.close();
    _contextController.close();
  }
} 