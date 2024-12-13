import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/models/works/tag.dart';
import 'package:asmrapp/widgets/common/tag_chip.dart';
import 'package:asmrapp/widgets/detail/work_info_header.dart';

class WorkInfo extends StatelessWidget {
  final Work work;

  const WorkInfo({
    super.key,
    required this.work,
  });

  String _getLocalizedTagName(Tag tag) {
    final zhName = tag.i18n?.zhCn?.name;
    if (zhName != null) return zhName;
    final jaName = tag.i18n?.jaJp?.name;
    if (jaName != null) return jaName;
    return tag.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkInfoHeader(work: work),
          const SizedBox(height: 12),
          if (work.tags != null && work.tags!.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: work.tags!
                  .map((tag) => TagChip(text: _getLocalizedTagName(tag)))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
