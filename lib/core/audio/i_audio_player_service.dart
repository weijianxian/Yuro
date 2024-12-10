import 'package:just_audio/just_audio.dart';

class AudioTrackInfo {
  final String title;
  final String artist;
  final String coverUrl;
  final String url;

  AudioTrackInfo({
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.url,
  });
}

abstract class IAudioPlayerService {
  Future<void> play(String url, {AudioTrackInfo? trackInfo});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
  
  Stream<PlayerState> get playerState;
  Stream<Duration?> get position;
  Stream<Duration?> get bufferedPosition;
  Stream<Duration?> get duration;
  
  AudioTrackInfo? get currentTrack;
}