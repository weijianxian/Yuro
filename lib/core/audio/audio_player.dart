import 'package:just_audio/just_audio.dart';
import 'audio_service.dart';

class AudioPlayerService implements AudioService {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> play(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      print('Error playing audio: $e');
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
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }

  @override
  Stream<PlayerState> get playerState => _player.playerStateStream;
}
