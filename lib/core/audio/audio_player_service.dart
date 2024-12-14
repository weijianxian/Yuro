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

class AudioPlayerService implements IAudioPlayerService {
  late final AudioPlayer _player;
  late final AudioNotificationService _notificationService;
  late final ConcatenatingAudioSource _playlist;
  late final PlaybackStateManager _stateManager;
  late final PlaybackController _playbackController;
  
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

      _playbackController = PlaybackController(
        player: _player,
        stateManager: _stateManager,
        playlist: _playlist,
      );

      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _notificationService.init();

      await restorePlaybackState();
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

  // 播放模式处理
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
    await _playbackController.seek(Duration.zero);
    await _playbackController.play();
  }

  Future<void> _handleLoopModeCompletion() async {
    if (_player.hasNext) {
      await _playbackController.next();
    } else {
      await _playbackController.seek(Duration.zero, index: 0);
      await _playbackController.play();
    }
  }

  Future<void> _handleSequenceModeCompletion() async {
    if (_player.hasNext) {
      await _playbackController.next();
    }
  }

  // IAudioPlayerService 实现
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

    await _playbackController.setPlaybackContext(context);
    await _playbackController.seek(Duration(milliseconds: state.position));
    await _playbackController.stop();
  }

  @override
  Future<void> dispose() async {
    await _notificationService.dispose();
    await _player.dispose();
  }

  // 状态访问
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
  PlaybackContext? get currentContext => _stateManager.currentContext;

  @override
  Stream<PlaybackContext?> get contextStream => _stateManager.contextStream;
}
