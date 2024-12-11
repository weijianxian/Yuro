import 'package:asmrapp/data/models/works/tag.dart';
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

  String _formatDuration(int? seconds) {
    if (seconds == null) return '';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkTitle(work: work),
          const SizedBox(height: 4),
          Row(
            children: [
              if (work.duration != null) ...[
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(work.duration),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: [
              if (work.circle?.name != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    work.circle?.name ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
              ...work.tags?.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getLocalizedTagName(tag),
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )).toList() ?? [],
            ],
          ),
          const SizedBox(height: 4),
          const Spacer(),
          WorkFooter(work: work),
        ],
      ),
    );
  }
}
