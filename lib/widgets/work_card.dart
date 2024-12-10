import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/work.dart';

class WorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const WorkCard({
    super.key,
    required this.work,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                work.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // RJ号和时长
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        work.id,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        work.duration,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 标题
                  Text(
                    work.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 创作者
                  Text(
                    work.circle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 标签
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: work.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 4),
                  // 发布日期
                  Text(
                    work.releaseDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 