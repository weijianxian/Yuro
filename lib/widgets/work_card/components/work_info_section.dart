import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'work_header.dart';
import 'work_title.dart';
import 'work_tags.dart';
import 'work_footer.dart';

class WorkInfoSection extends StatelessWidget {
  final Work work;

  const WorkInfoSection({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkHeader(work: work),
          const SizedBox(height: 4),
          WorkTitle(work: work),
          const SizedBox(height: 4),
          Text(
            work.circle?.name ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 8),
          WorkTags(work: work),
          const SizedBox(height: 4),
          const Spacer(),
          WorkFooter(work: work),
        ],
      ),
    );
  }
}
