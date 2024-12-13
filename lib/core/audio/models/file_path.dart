import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/utils/logger.dart';

/// 文件路径工具类
/// 用于在文件树中定位文件和获取同级文件
class FilePath {
  static const separator = '/';

  /// 获取文件的完整路径
  /// 返回类似 /folder1/folder2/file.mp3 的路径
  static String? getPath(Child targetFile, Files root) {
    AppLogger.debug('开始查找文件路径: ${targetFile.title}');
    final segments = _findPathSegments(root.children, targetFile);
    
    if (segments == null) {
      AppLogger.debug('未找到文件路径');
      return null;
    }

    final path = separator + segments.join(separator);
    AppLogger.debug('找到文件路径: $path');
    return path;
  }

  /// 递归查找文件路径段
  static List<String>? _findPathSegments(List<Child>? children, Child targetFile, [List<String> currentPath = const []]) {
    if (children == null) return null;

    for (final child in children) {
      if (child.title == targetFile.title && 
          child.mediaDownloadUrl == targetFile.mediaDownloadUrl && 
          child.type == targetFile.type &&
          child.size == targetFile.size) {  // size 作为额外验证
        return [...currentPath, child.title!];
      }

      if (child.type == 'folder' && child.children != null) {
        final result = _findPathSegments(
          child.children, 
          targetFile, 
          [...currentPath, child.title!]
        );
        if (result != null) return result;
      }
    }

    return null;
  }

  /// 获取同级文件列表
  /// 返回与目标文件在同一目录下的所有文件
  static List<Child> getSiblings(Child targetFile, Files root) {
    // AppLogger.debug('开始获取同级文件: ${targetFile.title}');
    
    // 获取目标文件的路径
    final path = getPath(targetFile, root);
    if (path == null) {
      AppLogger.debug('无法获取文件路径，返回空列表');
      return [];
    }

    // 获取父目录路径
    final parentPath = path.substring(0, path.lastIndexOf(separator));
    AppLogger.debug('父目录路径: $parentPath');

    // 查找父目录
    final parentDir = _findDirectoryByPath(root.children, parentPath);
    if (parentDir == null) {
      AppLogger.debug('未找到父目录，返回空列表');
      return [];
    }

    // AppLogger.debug('找到同级文件:');
    // for (final file in parentDir) {
    //   AppLogger.debug('- [${file.type}] ${file.title}');
    // }

    return parentDir;
  }

  /// 根据路径查找目录内容
  static List<Child>? _findDirectoryByPath(List<Child>? children, String path) {
    if (children == null || path.isEmpty) return null;

    // 如果是根路径，直接返回
    if (path == separator) return children;

    // 分割路径
    final segments = path.split(separator)
      ..removeWhere((s) => s.isEmpty);
    
    List<Child>? current = children;
    
    // 逐级查找目录
    for (final segment in segments) {
      final nextDir = current?.firstWhere(
        (child) => child.title == segment && child.type == 'folder',
        orElse: () => Child(),
      );
      
      if (nextDir?.title == null) return null;
      current = nextDir?.children;
    }

    return current;
  }
} 