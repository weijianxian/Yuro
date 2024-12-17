import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/widgets/common/tag_chip.dart';
import 'package:asmrapp/widgets/detail/work_stats_info.dart';

class WorkInfoHeader extends StatelessWidget {
  final Work work;

  const WorkInfoHeader({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          work.title ?? '',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        WorkStatsInfo(work: work),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (work.circle?.name != null)
              TagChip(
                text: work.circle?.name ?? '',
                backgroundColor: Colors.orange.withOpacity(0.2),
                textColor: Colors.orange[700],
              ),
            ...?work.vas?.map(
              (va) => TagChip(
                text: va['name'] ?? '',
                backgroundColor: Colors.green.withOpacity(0.2),
                textColor: Colors.green[700],
              ),
            ),
            if (work.hasSubtitle == true)
              TagChip(
                text: '字幕',
                backgroundColor: Colors.blue.withOpacity(0.2),
                textColor: Colors.blue[700],
              ),
          ],
        ),
      ],
    );
  }
} 