import 'package:asmrapp/core/audio/models/audio_track_info.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/data/models/works/work.dart';

class TrackInfoCreator {
  static AudioTrackInfo createTrackInfo({
    required String title,
    required String? artistName,
    required String? coverUrl,
    required String url,
    Duration? duration,
  }) {
    return AudioTrackInfo(
      title: title,
      artist: artistName ?? '',
      coverUrl: coverUrl ?? '',
      url: url,
      duration: duration,
    );
  }
  
  static AudioTrackInfo createFromFile(Child file, Work work, {Duration? duration}) {
    return createTrackInfo(
      title: file.title ?? '',
      artistName: work.circle?.name,
      coverUrl: work.mainCoverUrl,
      url: file.mediaDownloadUrl!,
      duration: duration,
    );
  }
} 