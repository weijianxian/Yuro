import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:asmrapp/utils/logger.dart';
import './i_audio_player_service.dart';
import './models/audio_track_info.dart';
import './models/playback_context.dart';
import './notification/audio_notification_service.dart';
import '../../data/repositories/audio/audio_cache_repository.dart';
import './models/play_mode.dart';

class AudioPlayerService implements IAudioPlayerService {
  late final AudioPlayer _player;
  late final AudioNotificationService _notificationService;
  late final AudioCacheRepository _cacheRepository;
  late final ConcatenatingAudioSource _playlist;
  AudioTrackInfo? _currentTrack;
  PlaybackContext? _currentContext;

  AudioPlayerService._internal() {
    _init();
  }

  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  Future<void> _init() async {
    _player = AudioPlayer();
    _notificationService = AudioNotificationService(_player);
    _cacheRepository = AudioCacheRepository();
    _playlist = ConcatenatingAudioSource(children: []);

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _notificationService.init();

      _player.playerStateStream.listen((state) {
        // AppLogger.debug('播放状态变化: $state');
        
        // 检查是否播放完成
        if (state.processingState == ProcessingState.completed) {
          _handlePlaybackCompletion();
        }
      });
    } catch (e) {
      AppLogger.error('音频播放器初始化失败', e);
    }
  }

  @override
  Future<void> play(String url, {AudioTrackInfo? trackInfo}) async {
    try {
      if (trackInfo != null) {
        _currentTrack = trackInfo;

        // AppLogger.debug('准备播放URL: $url');

        // 使用缓存音频源
        final audioSource = await _cacheRepository.getAudioSource(url);
        // AppLogger.debug('创建音频源成功: $url');

        try {
          await _player.stop(); // 先停止当前播放
          // AppLogger.debug('停止当前播放');

          await _player.setAudioSource(audioSource);
          // AppLogger.debug('设置音频源成功');
        } catch (e, stack) {
          AppLogger.error('设置音频源失败', e, stack);
          throw Exception('设置音频源失败: $e');
        }

        // 等待获取到音频时长后再更新通知栏
        try {
          final duration = _player.duration;
          // AppLogger.debug('获取音频时长成功: $duration');

          final updatedTrackInfo = AudioTrackInfo(
            title: trackInfo.title,
            artist: trackInfo.artist,
            coverUrl: trackInfo.coverUrl,
            url: trackInfo.url,
            duration: duration,
          );
          _notificationService.updateMetadata(updatedTrackInfo);
        } catch (e, stack) {
          AppLogger.error('获取音频时长失败', e, stack);
          // 不抛出异常，继续尝试播放
        }
      }

      try {
        await _player.play();
        AppLogger.debug('开始播放成功');
      } catch (e, stack) {
        AppLogger.error('开始播放失败', e, stack);
        throw Exception('开始播放失败: $e');
      }
    } catch (e, stack) {
      _currentTrack = null;
      AppLogger.error('播放失败', e, stack);
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
    _currentTrack = null;
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
  AudioTrackInfo? get currentTrack => _currentTrack;

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      AppLogger.debug('Seek failed: $e');
    }
  }

  @override
  Future<void> previous() async {
    try {
      if (_currentContext == null) {
        AppLogger.debug('无法切换上一曲：播放上下文为空');
        return;
      }

      // 使用 just_audio 的播放列表控制
      if (await _player.hasPrevious) {
        // 更新 context
        final previousFile = _currentContext!.getPreviousFile();
        if (previousFile != null) {
          _currentContext = _currentContext!.copyWithFile(previousFile);
          
          // 更新音轨信息
          final trackInfo = AudioTrackInfo(
            title: previousFile.title ?? '',
            artist: _currentContext!.work.circle?.name ?? '',
            coverUrl: _currentContext!.work.mainCoverUrl ?? '',
            url: previousFile.mediaDownloadUrl!,
            subtitleUrl: _currentContext!.getSubtitleFile()?.mediaDownloadUrl,
          );
          _currentTrack = trackInfo;
          _notificationService.updateMetadata(trackInfo);

          // 切换到上一曲
          await _player.seekToPrevious();
        }
      } else {
        AppLogger.debug('无法切换上一曲：已经是第一首');
      }
    } catch (e) {
      AppLogger.error('切换上一曲失败', e);
    }
  }

  @override
  Future<void> next() async {
    try {
      if (_currentContext == null) {
        AppLogger.debug('无法切换下一曲：播放上下文为空');
        return;
      }

      // 使用 just_audio 的播放列表控制
      if (await _player.hasNext) {
        // 更新 context
        final nextFile = _currentContext!.getNextFile();
        if (nextFile != null) {
          _currentContext = _currentContext!.copyWithFile(nextFile);
          
          // 更新音轨信息
          final trackInfo = AudioTrackInfo(
            title: nextFile.title ?? '',
            artist: _currentContext!.work.circle?.name ?? '',
            coverUrl: _currentContext!.work.mainCoverUrl ?? '',
            url: nextFile.mediaDownloadUrl!,
            subtitleUrl: _currentContext!.getSubtitleFile()?.mediaDownloadUrl,
          );
          _currentTrack = trackInfo;
          _notificationService.updateMetadata(trackInfo);

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
  PlaybackContext? get currentContext => _currentContext;

  @override
  Future<void> playWithContext(PlaybackContext context) async {
    try {
      AppLogger.debug('开始处理播放上下文');
      AppLogger.debug('当前文件标题: ${context.currentFile.title}');
      AppLogger.debug('播放列表数量: ${context.playlist.length}');
      
      _currentContext = context;

      // 构建播放列表
      final audioSources = await Future.wait(
        context.playlist.map((file) async {
          return await _cacheRepository.getAudioSource(file.mediaDownloadUrl!);
        })
      );

      // 清空并设置新的播放列表
      await _playlist.clear();
      await _playlist.addAll(audioSources);
      
      // 设置播放列表到播放器
      try {
        await _player.setAudioSource(_playlist, 
          initialIndex: context.currentIndex,
          initialPosition: Duration.zero
        );
      } catch (e, stack) {
        AppLogger.error('设置播放列表失败', e, stack);
        throw Exception('设置播放列表失败: $e');
      }

      // 创建当前曲目的音轨信息
      final trackInfo = AudioTrackInfo(
        title: context.currentFile.title ?? '',
        artist: context.work.circle?.name ?? '',
        coverUrl: context.work.mainCoverUrl ?? '',
        url: context.currentFile.mediaDownloadUrl!,
        subtitleUrl: context.getSubtitleFile()?.mediaDownloadUrl,
      );

      _currentTrack = trackInfo;
      _notificationService.updateMetadata(trackInfo);

      // 开始播放
      await _player.play();
      AppLogger.debug('开始播放成功');
    } catch (e, stack) {
      AppLogger.debug('播放上下文处理错误: $e');
      AppLogger.debug('错误堆栈: $stack');
      _currentContext = null;
      rethrow;
    }
  }

  // 处理播放完成
  void _handlePlaybackCompletion() async {
    try {
      if (_currentContext == null) return;

      switch (_currentContext!.playMode) {
        case PlayMode.single:
          // 单曲循环：重新播放当前曲目
          await _player.seek(Duration.zero);
          await _player.play();
          break;
          
        case PlayMode.loop:
          // 列表循环：如果是最后一首，跳回第一首
          if (await _player.hasNext) {
            await next();
          } else {
            await _player.seek(Duration.zero, index: 0);
            await _player.play();
          }
          break;
          
        case PlayMode.sequence:
          // 顺序播放：有下一曲就播放下一曲
          if (await _player.hasNext) {
            await next();
          }
          break;
      }
    } catch (e) {
      AppLogger.error('自动切换下一曲失败', e);
    }
  }
}
