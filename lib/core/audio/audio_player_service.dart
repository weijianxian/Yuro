import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:get_it/get_it.dart';
import './i_audio_player_service.dart';
import './models/audio_track_info.dart';
import './models/playback_context.dart';
import './notification/audio_notification_service.dart';
import './models/play_mode.dart';
import './storage/i_playback_state_repository.dart';
import './utils/audio_error_handler.dart';
import './state/playback_state_manager.dart';
import './controllers/playback_controller.dart';
import './events/playback_event_hub.dart';
import './events/playback_event.dart';

class AudioPlayerService implements IAudioPlayerService {
  late final AudioPlayer _player;
  late final AudioNotificationService _notificationService;
  late final ConcatenatingAudioSource _playlist;
  late final PlaybackStateManager _stateManager;
  late final PlaybackController _playbackController;
  final _eventHub = PlaybackEventHub();
  final _stateRepository = GetIt.I<IPlaybackStateRepository>();

  // 状态流控制器
  final _stateController = StreamController<PlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _bufferedPositionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();

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
        eventHub: _eventHub,
      );

      _playbackController = PlaybackController(
        player: _player,
        stateManager: _stateManager,
        playlist: _playlist,
      );

      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _notificationService.init();

       _stateManager.initStateListeners();

      await restorePlaybackState();
      _initEventListeners();
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

  void _initEventListeners() {
    // 播放状态事件
    _eventHub.playbackState.listen((event) {
      _stateController.add(event.state);
      _positionController.add(event.position);
      if (event.duration != null) {
        _durationController.add(event.duration);
      }
    });

    // 播放进度事件
    _eventHub.playbackProgress.listen((event) {
      _positionController.add(event.position);
      if (event.bufferedPosition != null) {
        _bufferedPositionController.add(event.bufferedPosition!);
      }
    });

    // 播放完成事件
    _eventHub.playbackState
        .where((event) => event.state.processingState == ProcessingState.completed)
        .listen(_handlePlaybackCompleted);
  }

  void _handlePlaybackCompleted(PlaybackStateEvent event) async {
    final context = _stateManager.currentContext;
    if (context == null) return;

    switch (context.playMode) {
      case PlayMode.single:
        await _playbackController.seek(Duration.zero);
        await _playbackController.play();
        break;
      case PlayMode.loop:
        if (_player.hasNext) {
          await _playbackController.next();
        } else {
          await _playbackController.seek(Duration.zero, index: 0);
          await _playbackController.play();
        }
        break;
      case PlayMode.sequence:
        if (_player.hasNext) {
          await _playbackController.next();
        }
        break;
    }
  }

  // IAudioPlayerService 实现
  @override
  Stream<PlayerState> get playerState => _stateController.stream;
  
  @override
  Stream<Duration> get position => _positionController.stream;
  
  @override
  Stream<Duration> get bufferedPosition => _bufferedPositionController.stream;
  
  @override
  Stream<Duration?> get duration => _durationController.stream;

  @override
  Future<void> pause() => _playbackController.pause();

  @override
  Future<void> resume() => _playbackController.play();

  @override
  Future<void> stop() async {
    await _playbackController.stop();
    _stateManager.clearState();
  }

  @override
  Future<void> seek(Duration position) => _playbackController.seek(position);

  @override
  Future<void> previous() => _playbackController.previous();

  @override
  Future<void> next() => _playbackController.next();

  @override
  Future<void> playWithContext(PlaybackContext context) => 
    _playbackController.setPlaybackContext(context);

  @override
  Future<void> savePlaybackState() => _stateManager.saveState();

  @override
  Future<void> restorePlaybackState() async {
    final state = await _stateManager.loadState();
    if (state == null) return;

    final context = PlaybackContext(
      work: state.work,
      files: state.files,
      currentFile: state.currentFile,
      playMode: state.playMode,
    );

    final position = Duration(milliseconds: state.position);
    await _playbackController.setPlaybackContext(context, initialPosition: position);
    await _playbackController.stop();
  }

  @override
  Future<void> dispose() async {
    _player.dispose();
    _notificationService.dispose();
  }

  @override
  AudioTrackInfo? get currentTrack => _stateManager.currentTrack;

  @override
  PlaybackContext? get currentContext => _stateManager.currentContext;

  @override
  Stream<PlaybackContext?> get contextStream => _stateManager.contextStream;
}
