class Subtitle {
  final Duration start;
  final Duration end;
  final String text;

  const Subtitle({
    required this.start,
    required this.end,
    required this.text,
  });

  @override
  String toString() => '$start --> $end: $text';
}

class SubtitleList {
  final List<Subtitle> subtitles;
  int _currentIndex = -1;

  SubtitleList(this.subtitles);

  Subtitle? getCurrentSubtitle(Duration position) {
    // 如果当前索引有效，先检查当前字幕是否仍然有效
    if (_currentIndex >= 0 && _currentIndex < subtitles.length) {
      final current = subtitles[_currentIndex];
      if (position >= current.start && position <= current.end) {
        return current;
      }
    }

    // 查找新的当前字幕
    _currentIndex = subtitles.indexWhere(
      (subtitle) => position >= subtitle.start && position <= subtitle.end
    );

    return _currentIndex >= 0 ? subtitles[_currentIndex] : null;
  }

  static SubtitleList parse(String vttContent) {
    final lines = vttContent.split('\n');
    final subtitles = <Subtitle>[];
    
    int i = 0;
    // 跳过 WEBVTT 头部
    while (i < lines.length && !lines[i].contains('-->')) {
      i++;
    }

    while (i < lines.length) {
      final line = lines[i].trim();
      
      // 解析时间戳行
      if (line.contains('-->')) {
        final times = line.split('-->');
        if (times.length == 2) {
          final start = _parseTimestamp(times[0].trim());
          final end = _parseTimestamp(times[1].trim());
          
          // 收集字幕文本
          i++;
          String text = '';
          while (i < lines.length && lines[i].trim().isNotEmpty) {
            if (text.isNotEmpty) text += '\n';
            text += lines[i].trim();
            i++;
          }
          
          if (start != null && end != null && text.isNotEmpty) {
            subtitles.add(Subtitle(
              start: start,
              end: end,
              text: text,
            ));
          }
        }
      }
      i++;
    }

    return SubtitleList(subtitles);
  }

  static Duration? _parseTimestamp(String timestamp) {
    try {
      final parts = timestamp.split(':');
      if (parts.length == 3) {
        final seconds = parts[2].split('.');
        return Duration(
          hours: int.parse(parts[0]),
          minutes: int.parse(parts[1]),
          seconds: int.parse(seconds[0]),
          milliseconds: seconds.length > 1 ? int.parse(seconds[1].padRight(3, '0')) : 0,
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
} 