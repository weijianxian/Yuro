import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/work.dart';

class WorkHeader extends StatelessWidget {
  final Work work;

  const WorkHeader({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    if (work.rateCount == 0) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          work.rateAverage.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
} 