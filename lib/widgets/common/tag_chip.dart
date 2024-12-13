import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const TagChip({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
      ),
    );
  }
} 