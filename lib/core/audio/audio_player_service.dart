import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:asmrapp/utils/logger.dart';
import './i_audio_player_service.dart';
import './models/audio_track_info.dart';
import './models/playback_context.dart';
import './models/subtitle.dart';
import './notification/audio_notification_service.dart';
import '../../data/repositories/audio/audio_cache_repository.dart';
import 'package:http/http.dart' as http;

class AudioPlayerService implements IAudioPlayerService {
  late final AudioPlayer _player;
  late final AudioNotificationService _notificationService;
  late final AudioCacheRepository _cacheRepository;
  AudioTrackInfo? _currentTrack;
  PlaybackContext? _currentContext;
  SubtitleList? _subtitleList;
  Subtitle? _currentSubtitle;

  AudioPlayerService._internal() {
    _init();
  }

  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  Future<void> _init() async {
    _player = AudioPlayer();
    _notificationService = AudioNotificationService(_player);
    _cacheRepository = AudioCacheRepository();

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _notificationService.init();

      _player.playerStateStream.listen((state) {
        AppLogger.debug('播放状态变化: $state');
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

        AppLogger.debug('准备播放URL: $url');

        // 使用缓存音频源
        final audioSource = await _cacheRepository.getAudioSource(url);
        AppLogger.debug('创建音频源成功: $url');

        try {
          await _player.stop(); // 先停止当前播放
          AppLogger.debug('停止当前播放');

          await _player.setAudioSource(audioSource);
          AppLogger.debug('设置音频源成功');
        } catch (e, stack) {
          AppLogger.error('设置音频源失败', e, stack);
          throw Exception('设置音频源失败: $e');
        }

        // 等待获取到音频时长后再更新通知栏
        try {
          final duration = _player.duration;
          AppLogger.debug('获取音频时长成功: $duration');

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
    // 由于目前没有播放列表管理，暂时只实现重新播放当前曲目
    try {
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      AppLogger.debug('Previous failed: $e');
    }
  }

  @override
  Future<void> next() async {
    // 由于目前没有播放列表管理，暂时只实现重新播放当前曲目
    try {
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      AppLogger.debug('Next failed: $e');
    }
  }

  @override
  PlaybackContext? get currentContext => _currentContext;

  @override
  Future<void> playWithContext(PlaybackContext context) async {
    try {
      AppLogger.debug('开始处理播放上下文');
      AppLogger.debug('当前文件标题: ${context.currentFile.title}');
      AppLogger.debug('文件列表数量: ${context.files.children?.length ?? 0}');
      
      _currentContext = context;
      _subtitleList = null;
      _currentSubtitle = null;
      
      // 检查是否有字幕文件
      AppLogger.debug('开始查找字幕文件...');
      final subtitleFile = context.getSubtitleFile();
      final subtitleUrl = subtitleFile?.mediaDownloadUrl;
      AppLogger.debug('字幕URL: ${subtitleUrl ?? '无'}');
      
      final trackInfo = AudioTrackInfo(
        title: context.currentFile.title ?? '',
        artist: context.work.circle?.name ?? '',
        coverUrl: context.work.mainCoverUrl ?? '',
        url: context.currentFile.mediaDownloadUrl!,
        subtitleUrl: subtitleUrl,
      );

      AppLogger.debug('准备开始播放音频');
      // 使用现有的播放方法
      play(context.currentFile.mediaDownloadUrl!, trackInfo: trackInfo);

      // 如果有字幕，加载字幕
      if (subtitleUrl != null) {
        AppLogger.debug('开始加载字幕文件');
        await _loadSubtitle(subtitleUrl);
      } else {
        AppLogger.debug('没有找到字幕文件，跳过字幕加载');
      }
    } catch (e, stack) {
      AppLogger.debug('播放上下文处理错误: $e');
      AppLogger.debug('错误堆栈: $stack');
      _currentContext = null;
      rethrow;
    }
  }

  Future<void> _loadSubtitle(String url) async {
    try {
      AppLogger.debug('正在下载字幕文件: $url');
      final response = await http.get(Uri.parse(url));
      AppLogger.debug('字幕文件下载状态: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final content = response.body;
        AppLogger.debug('字幕文件内容预览: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
        
        _subtitleList = SubtitleList.parse(content);
        AppLogger.debug('字幕解析完成，字幕数量: ${_subtitleList?.subtitles.length ?? 0}');
        
        // 开始监听播放进度以更新字幕
        _player.positionStream.listen((position) {
          if (_subtitleList != null) {
            final newSubtitle = _subtitleList!.getCurrentSubtitle(position);
            if (newSubtitle != _currentSubtitle) {
              _currentSubtitle = newSubtitle;
              AppLogger.debug('字幕服务更新: ${newSubtitle?.text ?? '无字幕'}');
            }
          }
        });
      }
    } catch (e) {
      AppLogger.debug('字幕加载失败: $e');
      _subtitleList = null;
    }
  }

  // 添加字幕相关的 getter
  SubtitleList? get subtitleList => _subtitleList;
  Subtitle? get currentSubtitle => _currentSubtitle;
}
