import 'package:flutter/material.dart';

class WorkActionButtons extends StatelessWidget {
  final VoidCallback onRecommendationsTap;

  const WorkActionButtons({
    super.key,
    required this.onRecommendationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.favorite_border,
            label: '收藏',
            onTap: () {
              // TODO: 实现收藏功能
            },
          ),
          _ActionButton(
            icon: Icons.bookmark_border,
            label: '标记',
            onTap: () {
              // TODO: 实现标记功能
            },
          ),
          _ActionButton(
            icon: Icons.star_border,
            label: '评分',
            onTap: () {
              // TODO: 实现评分功能
            },
          ),
          _ActionButton(
            icon: Icons.recommend,
            label: '相关推荐',
            onTap: onRecommendationsTap,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
} 