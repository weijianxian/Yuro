import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/widgets/work_grid.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/screens/detail_screen.dart';

class WorkGridView extends StatelessWidget {
  final List<Work> works;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final Widget? customEmptyWidget;
  final WorkLayoutStrategy layoutStrategy;

  const WorkGridView({
    super.key,
    required this.works,
    required this.isLoading,
    this.error,
    this.onRetry,
    this.emptyMessage,
    this.customEmptyWidget,
    this.layoutStrategy = const WorkLayoutStrategy(),
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error!),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('重试'),
              ),
            ],
          ],
        ),
      );
    }

    if (works.isEmpty) {
      if (customEmptyWidget != null) {
        return customEmptyWidget!;
      }
      if (emptyMessage != null) {
        return Center(
          child: Text(
            emptyMessage!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: layoutStrategy.getPadding(context),
          sliver: WorkGrid(
            works: works,
            layoutStrategy: layoutStrategy,
            onWorkTap: (work) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(work: work),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}