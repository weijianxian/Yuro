import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/work.dart';

class WorkTags extends StatelessWidget {
  final Work work;

  const WorkTags({
    super.key,
    required this.work,
  });

  String _getLocalizedTagName(Tag tag) {
    // 优先使用中文名称
    final zhName = tag.i18n['zh-cn']?.name;
    if (zhName != null) return zhName;

    // 如果没有中文名称，使用日文名称
    final jaName = tag.i18n['ja-jp']?.name;
    if (jaName != null) return jaName;

    // 如果都没有，使用原始名称
    return tag.name;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: work.tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _getLocalizedTagName(tag),
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      )).toList(),
    );
  }
} 