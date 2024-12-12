class AudioTrackInfo {
  final String title;
  final String artist;
  final String coverUrl;
  final String url;
  final String? subtitleUrl;
  final Duration? duration;

  AudioTrackInfo({
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.url,
    this.subtitleUrl,
    this.duration,
  });
}
