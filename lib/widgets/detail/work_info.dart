import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/widgets/detail/work_stats.dart';
import 'package:asmrapp/widgets/detail/work_tags_list.dart';

class WorkInfo extends StatelessWidget {
  final Work work;

  const WorkInfo({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            work.title ?? '',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            work.circle?.name ?? '',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          WorkStats(work: work),
          const SizedBox(height: 16),
          WorkTagsList(tags: work.tags ?? []),
        ],
      ),
    );
  }
}
