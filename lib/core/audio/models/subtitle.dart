import 'dart:math' as math;

class Subtitle {
  final Duration start;
  final Duration end;
  final String text;
  final int index;

  const Subtitle({
    required this.start,
    required this.end,
    required this.text,
    required this.index,
  });

  Subtitle? getNext(SubtitleList list) {
    if (index < list.subtitles.length - 1) {
      return list.subtitles[index + 1];
    }
    return null;
  }

  Subtitle? getPrevious(SubtitleList list) {
    if (index > 0) {
      return list.subtitles[index - 1];
    }
    return null;
  }

  @override
  String toString() => '$start --> $end: $text';
}

class SubtitleList {
  final List<Subtitle> subtitles;
  int _currentIndex = -1;

  SubtitleList(List<Subtitle> subtitles) 
    : subtitles = subtitles.asMap().entries.map(
        (entry) => Subtitle(
          start: entry.value.start,
          end: entry.value.end,
          text: entry.value.text,
          index: entry.key,
        )
      ).toList();

  int get currentIndex => _currentIndex;

  Subtitle? getCurrentSubtitle(Duration position) {
    if (_currentIndex >= 0 && _currentIndex < subtitles.length) {
      final current = subtitles[_currentIndex];
      if (position >= current.start && position <= current.end) {
        return current;
      }
    }

    _currentIndex = subtitles.indexWhere(
      (subtitle) => position >= subtitle.start && position <= subtitle.end
    );

    return _currentIndex >= 0 ? subtitles[_currentIndex] : null;
  }

  List<Subtitle> getSubtitlesInRange(int start, int count) {
    if (start < 0 || start >= subtitles.length) return [];
    final end = math.min(start + count, subtitles.length);
    return subtitles.sublist(start, end);
  }

  (Subtitle?, Subtitle?, Subtitle?) getCurrentContext() {
    if (_currentIndex == -1) return (null, null, null);
    
    final previous = _currentIndex > 0 ? subtitles[_currentIndex - 1] : null;
    final current = subtitles[_currentIndex];
    final next = _currentIndex < subtitles.length - 1 ? subtitles[_currentIndex + 1] : null;
    
    return (previous, current, next);
  }

  static SubtitleList parse(String vttContent) {
    final lines = vttContent.split('\n');
    final subtitles = <Subtitle>[];
    
    int i = 0;
    while (i < lines.length && !lines[i].contains('-->')) {
      i++;
    }

    while (i < lines.length) {
      final line = lines[i].trim();
      
      if (line.contains('-->')) {
        final times = line.split('-->');
        if (times.length == 2) {
          final start = _parseTimestamp(times[0].trim());
          final end = _parseTimestamp(times[1].trim());
          
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
              index: subtitles.length,
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