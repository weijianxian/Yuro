import 'package:asmrapp/core/subtitle/i_subtitle_service.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:asmrapp/core/audio/i_audio_player_service.dart';
import 'package:asmrapp/core/audio/models/subtitle.dart';
import 'dart:async';
import 'package:asmrapp/core/subtitle/subtitle_loader.dart';

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
  final IAudioPlayerService _audioService = GetIt.I<IAudioPlayerService>();
  final ISubtitleService _subtitleService = GetIt.I<ISubtitleService>();
  final _subtitleLoader = SubtitleLoader();

  bool _isPlaying = false;
  Track? _currentTrack;
  Duration? _position;
  Duration? _duration;
  Subtitle? _currentSubtitle;

  final List<StreamSubscription> _subscriptions = [];

  String? _currentTrackUrl;

  static const _tag = 'PlayerViewModel';

  PlayerViewModel() {
    _initStreams();
    _initCurrentTrack();
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

    _audioService.playerState.first.then((state) {
      if (state.playing || state.processingState == ProcessingState.ready) {
        _isPlaying = state.playing;
        notifyListeners();
      }
    });
  }

  void _initStreams() {
    _initPlayerStateStream();
    _initPositionStream();
    _initDurationStream();
    _initSubtitleStreams();
  }

  void _initPlayerStateStream() {
    _subscriptions.add(
      _audioService.playerState.listen(
        _handlePlayerStateChange,
        onError: (error) => debugPrint('$_tag - 播放状态流错误: $error'),
      ),
    );
  }

  void _handlePlayerStateChange(PlayerState state) {
    _isPlaying = state.playing;
    _updateCurrentTrack();
    notifyListeners();
  }

  void _updateCurrentTrack() {
    final currentTrack = _audioService.currentTrack;
    if (currentTrack != null && _currentTrackUrl != currentTrack.url) {
      _subtitleService.clearSubtitle();
      
      _currentTrackUrl = currentTrack.url;
      _currentTrack = Track(
        title: currentTrack.title,
        artist: currentTrack.artist,
        coverUrl: currentTrack.coverUrl,
      );
      _loadSubtitleIfAvailable();
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

  void _initPositionStream() {
    _subscriptions.add(
      _audioService.position.listen(
        (pos) {
          _position = pos;
          if (pos != null) {
            _subtitleService.updatePosition(pos);
          }
          notifyListeners();
        },
        onError: (error) => debugPrint('$_tag - 播放进度流错误: $error'),
      ),
    );
  }

  void _initDurationStream() {
    _subscriptions.add(
      _audioService.duration.listen(
        (dur) {
          _duration = dur;
          notifyListeners();
        },
        onError: (error) => debugPrint('$_tag - 音频时长流错误: $error'),
      ),
    );
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
