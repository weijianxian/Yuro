import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/tag.dart';

class WorkTagsList extends StatelessWidget {
  final List<Tag> tags;

  const WorkTagsList({
    super.key,
    required this.tags,
  });

  String _getLocalizedTagName(Tag tag) {
    // 优先使用中文名称
    final zhName = tag.i18n?.zhCn?.name;
    if (zhName != null) return zhName;

    // 如果没有中文名称，使用日文名称
    final jaName = tag.i18n?.jaJp?.name;
    if (jaName != null) return jaName;

    // 如果都没有，使用原始名称
    return tag.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => Chip(
        label: Text(
          _getLocalizedTagName(tag),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      )).toList(),
    );
  }
} 