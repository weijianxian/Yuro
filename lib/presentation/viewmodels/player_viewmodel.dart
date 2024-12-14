import 'package:asmrapp/core/subtitle/i_subtitle_service.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:asmrapp/core/audio/i_audio_player_service.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'dart:async';
import 'package:asmrapp/core/subtitle/subtitle_loader.dart';
import 'package:asmrapp/core/audio/events/playback_event_hub.dart';

class Track {
  final String title;
  final String artist;
  final String coverUrl;

  Track({
    required this.title,
    required this.artist,
    required this.coverUrl,
  });
}

class PlayerViewModel extends ChangeNotifier {
  final IAudioPlayerService _audioService;
  final PlaybackEventHub _eventHub;
  final ISubtitleService _subtitleService;
  final _subtitleLoader = SubtitleLoader();

  bool _isPlaying = false;
  Track? _currentTrack;
  Duration? _position;
  Duration? _duration;
  Subtitle? _currentSubtitle;

  final List<StreamSubscription> _subscriptions = [];

  static const _tag = 'PlayerViewModel';

  PlayerViewModel({
    required IAudioPlayerService audioService,
    required PlaybackEventHub eventHub,
    required ISubtitleService subtitleService,
  }) : _audioService = audioService,
       _eventHub = eventHub,
       _subtitleService = subtitleService {
    _initStreams();
    _initCurrentTrack();
  }

  void _initStreams() {
    // 播放状态事件
    _subscriptions.add(
      _eventHub.playbackState.listen(
        (event) {
          _isPlaying = event.state.playing;
          _position = event.position;
          _duration = event.duration;
          notifyListeners();
        },
        onError: (error) => debugPrint('$_tag - 播放状态流错误: $error'),
      ),
    );

    // 音轨变更事件
    _subscriptions.add(
      _eventHub.trackChange.listen(
        (event) {
          _currentTrack = Track(
            title: event.track.title,
            artist: event.track.artist,
            coverUrl: event.track.coverUrl,
          );
          notifyListeners();
        },
        onError: (error) => debugPrint('$_tag - 音轨变更流错误: $error'),
      ),
    );

    // 播放进度事件
    _subscriptions.add(
      _eventHub.playbackProgress.listen(
        (event) {
          _position = event.position;
          if (_position != null) {
            _subtitleService.updatePosition(_position!);
          }
          notifyListeners();
        },
        onError: (error) => debugPrint('$_tag - 播放进度流错误: $error'),
      ),
    );

    // 上下文变更事件
    _subscriptions.add(
      _eventHub.contextChange.listen(
        (event) => _loadSubtitleIfAvailable(),
        onError: (error) => debugPrint('$_tag - 上下文流错误: $error'),
      ),
    );

    _initSubtitleStreams();
  }

  void _initCurrentTrack() {
    final currentTrack = _audioService.currentTrack;
    if (currentTrack != null) {
      _currentTrack = Track(
        title: currentTrack.title,
        artist: currentTrack.artist,
        coverUrl: currentTrack.coverUrl,
      );
      notifyListeners();
    }
  }

  void _loadSubtitleIfAvailable() {
    final currentContext = _audioService.currentContext;
    if (currentContext != null) {
      final subtitleFile = _subtitleLoader.findSubtitleFile(
        currentContext.currentFile,
        currentContext.files
      );
      if (subtitleFile?.mediaDownloadUrl != null) {
        _subtitleService.loadSubtitle(subtitleFile!.mediaDownloadUrl!);
      } else {
        _subtitleService.clearSubtitle();
        AppLogger.debug('未找到字幕文件，清除现有字幕');
      }
    } else {
      _subtitleService.clearSubtitle();
      AppLogger.debug('无播放上下文，清除现有字幕');
    }
  }

  void _initSubtitleStreams() {
    _subscriptions.add(
      _subtitleService.subtitleStream.listen(
        (subtitleList) {
          debugPrint('$_tag - 字幕列表更新: ${subtitleList != null ? '已加载' : '未加载'}');
        },
        onError: (error) => debugPrint('$_tag - 字幕流错误: $error'),
      ),
    );

    _subscriptions.add(
      _subtitleService.currentSubtitleStream.listen(
        (subtitle) {
          _currentSubtitle = subtitle;
          notifyListeners();
        },
        onError: (error) => debugPrint('$_tag - 当前字幕流错误: $error'),
      ),
    );
  }

  bool get isPlaying => _isPlaying;
  Track? get currentTrack => _currentTrack;
  Duration? get position => _position;
  Duration? get duration => _duration;
  Subtitle? get currentSubtitle => _currentSubtitle;

  Future<void> playPause() async {
    if (_isPlaying) {
      _audioService.pause();
    } else {
      _audioService.resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> previous() async {
    await _audioService.previous();
  }

  Future<void> next() async {
    await _audioService.next();
  }

  Future<void> stop() async {
    await _audioService.stop();
    _position = Duration.zero;
    notifyListeners();
  }

  void setTrack(Track track) {
    _currentTrack = track;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
