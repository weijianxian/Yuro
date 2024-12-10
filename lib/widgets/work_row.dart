import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/work.dart';
import 'package:asmrapp/widgets/work_card.dart';

class WorkRow extends StatelessWidget {
  final List<Work> works;
  final void Function(Work work)? onWorkTap;
  final double spacing;

  const WorkRow({
    super.key,
    required this.works,
    this.onWorkTap,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < works.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(
            child: WorkCard(
              work: works[i],
              onTap: onWorkTap != null ? () => onWorkTap!(works[i]) : null,
            ),
          ),
        ],
      ],
    );
  }
} 