class AudioTrackInfo {
  final String title;
  final String artist;
  final String coverUrl;
  final String url;
  final Duration? duration;

  AudioTrackInfo({
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.url,
    this.duration,
  });
} 