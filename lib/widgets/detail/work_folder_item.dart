import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:asmrapp/widgets/detail/work_file_item.dart';

class WorkFolderItem extends StatelessWidget {
  final Child folder;
  final double indentation;
  final Function(Child file)? onFileTap;

  // 支持的音频格式列表，按优先级排序
  static const _audioFormats = ['.mp3', '.wav'];

  const WorkFolderItem({
    super.key,
    required this.folder,
    required this.indentation,
    this.onFileTap,
  });

  bool _containsAudioFile(Child folder, [String? specificFormat]) {
    if (folder.children == null) return false;

    for (final child in folder.children!) {
      if (child.type == 'folder') {
        if (_containsAudioFile(child, specificFormat)) return true;
      } else {
        final fileName = child.title?.toLowerCase() ?? '';
        if (specificFormat != null) {
          if (fileName.endsWith(specificFormat)) return true;
        } else {
          // 如果没有指定格式，按优先级检查所有支持的格式
          for (final format in _audioFormats) {
            if (fileName.endsWith(format)) return true;
          }
        }
      }
    }
    return false;
  }

  bool _shouldExpandFolder(Child folder) {
    // 首先检查是否包含MP3文件
    if (_containsAudioFile(folder, '.mp3')) {
      // AppLogger.debug('文件夹包含MP3文件: ${folder.title}');
      return true;
    }

    // 如果没有MP3文件，检查是否包含WAV文件
    if (_containsAudioFile(folder, '.wav')) {
      // AppLogger.debug('文件夹包含WAV文件: ${folder.title}');
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final shouldExpand = _shouldExpandFolder(folder);
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: Padding(
        padding: EdgeInsets.only(left: indentation),
        child: ExpansionTile(
          title: Text(
            folder.title ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: const Icon(Icons.folder, color: Colors.amber),
          initiallyExpanded: shouldExpand,
          children: folder.children
                  ?.map((child) => child.type == 'folder'
                      ? WorkFolderItem(
                          folder: child,
                          indentation: indentation + 16.0,
                          onFileTap: onFileTap,
                        )
                      : WorkFileItem(
                          file: child,
                          indentation: indentation + 16.0,
                          onFileTap: onFileTap,
                        ))
                  .toList() ??
              [],
          onExpansionChanged: (expanded) {
            AppLogger.debug(
              '${expanded ? "展开" : "折叠"}文件夹: ${folder.title}',
            );
          },
        ),
      ),
    );
  }
}
