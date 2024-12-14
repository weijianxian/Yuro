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

class PlaybackStateManager {
  final AudioPlayer _player;
  final AudioNotificationService _notificationService;
  final IPlaybackStateRepository _stateRepository;
  final StreamController<PlaybackContext?> _contextController;

  AudioTrackInfo? _currentTrack;
  PlaybackContext? _currentContext;

  PlaybackStateManager({
    required AudioPlayer player,
    required AudioNotificationService notificationService,
    required IPlaybackStateRepository stateRepository,
    required StreamController<PlaybackContext?> contextController,
  }) : _player = player,
       _notificationService = notificationService,
       _stateRepository = stateRepository,
       _contextController = contextController;

  // 状态访问器
  AudioTrackInfo? get currentTrack => _currentTrack;
  PlaybackContext? get currentContext => _currentContext;
  Stream<PlaybackContext?> get contextStream => _contextController.stream;

  // 状态更新方法
  void updateContext(PlaybackContext? context) {
    _currentContext = context;
    _contextController.add(context);
  }

  void updateTrackInfo(AudioTrackInfo track) {
    _currentTrack = track;
    _notificationService.updateMetadata(track);
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

  // 状态转换方法
  void updateTrackFromFile(Child file, Work work) {
    final trackInfo = TrackInfoCreator.createFromFile(file, work);
    updateTrackInfo(trackInfo);
  }

  void clearState() {
    _currentTrack = null;
    _currentContext = null;
    _contextController.add(null);
  }

  // 初始化状态监听
  void initStateListeners() {
    // 播放状态变化监听
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onPlaybackCompleted();
      }
      saveState();
    });

    // 定期保存状态
    Timer.periodic(const Duration(seconds: 30), (_) {
      saveState();
    });
  }

  // 播放完成处理
  void _onPlaybackCompleted() {
    if (_currentContext == null) return;
    
    // 通知外部处理播放完成
    _playbackCompletionController.add(_currentContext!.playMode);
  }

  // 播放完成事件流
  final _playbackCompletionController = StreamController<PlayMode>.broadcast();
  Stream<PlayMode> get playbackCompletionStream => _playbackCompletionController.stream;

  // 状态更新方法增强
  void updateTrackAndContext(Child file, Work work) {
    // 更新上下文
    if (_currentContext != null) {
      updateContext(_currentContext!.copyWithFile(file));
    }
    
    // 更新音轨信息
    updateTrackFromFile(file, work);
  }

  void dispose() {
    _contextController.close();
    _playbackCompletionController.close();
  }
} 