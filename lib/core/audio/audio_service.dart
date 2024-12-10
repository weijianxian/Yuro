import 'package:just_audio/just_audio.dart';

abstract class AudioService {
  Future<void> play(String url);
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();
  
  Stream<PlayerState> get playerState;
} 