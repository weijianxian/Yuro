import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:asmrapp/utils/file_size_formatter.dart';

class WorkFileItem extends StatelessWidget {
  final Child file;
  final double indentation;
  final Function(Child file)? onFileTap;

  const WorkFileItem({
    super.key,
    required this.file,
    required this.indentation,
    this.onFileTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMp3 = file.title?.toLowerCase().endsWith('.mp3') ?? false;
    return Padding(
      padding: EdgeInsets.only(left: indentation),
      child: ListTile(
        title: Text(file.title ?? ''),
        subtitle: Text(FileSizeFormatter.format(file.size)),
        leading: Icon(
          isMp3 ? Icons.audio_file : Icons.insert_drive_file,
          color: isMp3 ? Colors.green : Colors.blue,
        ),
        dense: true,
        onTap: () {
          AppLogger.debug('点击文件: ${file.title}');
          onFileTap?.call(file);
        },
      ),
    );
  }
}
