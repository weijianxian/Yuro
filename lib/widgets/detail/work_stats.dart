import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';

class WorkStats extends StatelessWidget {
  final Work work;

  const WorkStats({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if ((work.rateCount ?? 0) > 0) ...[
          const Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '${work.rateAverage2dp ?? 0.0}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
        ],
        const Icon(Icons.download),
        const SizedBox(width: 4),
        Text(
          '${work.dlCount ?? 0}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (work.release != null) ...[
          const SizedBox(width: 16),
          const Icon(Icons.calendar_today),
          const SizedBox(width: 4),
          Text(
            work.release!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}
