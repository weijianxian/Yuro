import 'package:just_audio/just_audio.dart';

abstract class IAudioPlayerService {
  Future<void> play(String url);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
  
  Stream<PlayerState> get playerState;
  Stream<Duration?> get position;
  Stream<Duration?> get bufferedPosition;
  Stream<Duration?> get duration;
}