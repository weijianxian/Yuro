import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:asmrapp/data/models/work.dart';

class WorkCard extends StatelessWidget {
  final Work work;
  final VoidCallback? onTap;

  const WorkCard({
    super.key,
    required this.work,
    this.onTap,
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: work.mainCoverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID和评分
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RJ${work.id}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (work.rateCount > 0)
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                work.rateAverage.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
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
                      work.circleName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
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
                          _getLocalizedTagName(tag),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 4),
                    // 发布日期和下载数
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          work.release,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${work.dlCount}次下载',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 