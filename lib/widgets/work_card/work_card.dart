import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/work.dart';
import 'components/work_cover_image.dart';
import 'components/work_info_section.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WorkCoverImage(
              imageUrl: work.mainCoverUrl,
              rjNumber: 'RJ${work.id}',
            ),
            Expanded(
              child: WorkInfoSection(work: work),
            ),
          ],
        ),
      ),
    );
  }
} 