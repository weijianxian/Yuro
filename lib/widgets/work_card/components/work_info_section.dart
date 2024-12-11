import 'package:asmrapp/data/models/works/tag.dart';
import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'work_header.dart';
import 'work_title.dart';
import 'work_tags_panel.dart';
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
              const Spacer(),
              if (work.hasSubtitle == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '字幕',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          WorkTagsPanel(work: work),
          const SizedBox(height: 4),
          const Spacer(),
          WorkFooter(work: work),
        ],
      ),
    );
  }
}
