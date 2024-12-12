import 'package:just_audio/just_audio.dart';
import './models/audio_track_info.dart';

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

  Future<void> seek(Duration position);
  Future<void> previous();
  Future<void> next();
}
