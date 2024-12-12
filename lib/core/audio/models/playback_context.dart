import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/data/models/files/child.dart';

class PlaybackContext {
  final Work work;
  final Files files;
  final Child currentFile;

  const PlaybackContext({
    required this.work,
    required this.files,
    required this.currentFile,
  });

  // 便捷方法：获取字幕文件
  Child? getSubtitleFile() {
    if (files.children == null) return null;
    
    final audioTitle = _getBaseName(currentFile.title);
    try {
      return files.children!.firstWhere(
        (file) => 
          file.type?.toLowerCase() == 'vtt' && 
          _getBaseName(file.title) == audioTitle,
      );
    } catch (e) {
      return null;
    }
  }

  // 便捷方法：获取可播放文件列表
  List<Child> getPlayableFiles() {
    if (files.children == null) return [];
    return files.children!.where((file) => 
      file.mediaDownloadUrl != null && 
      file.type?.toLowerCase() != 'vtt'
    ).toList();
  }

  // 工具方法：获取文件名（不含扩展名）
  String? _getBaseName(String? filename) {
    if (filename == null) return null;
    return filename.replaceAll(RegExp(r'\.[^.]+$'), '');
  }
} 