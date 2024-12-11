import 'package:asmrapp/widgets/mini_player/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/widgets/detail/work_cover.dart';
import 'package:asmrapp/widgets/detail/work_info.dart';
import 'package:asmrapp/widgets/detail/work_files_list.dart';
import 'package:asmrapp/widgets/detail/work_files_skeleton.dart';
import 'package:asmrapp/presentation/viewmodels/detail_viewmodel.dart';

class DetailScreen extends StatelessWidget {
  final Work work;

  const DetailScreen({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailViewModel(
        work: work,
      )..loadFiles(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('RJ${work.id ?? 0}'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkCover(
                imageUrl: work.mainCoverUrl ?? '',
                rjNumber: 'RJ${work.id ?? 0}',
              ),
              WorkInfo(work: work),
              Consumer<DetailViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading) {
                    return const WorkFilesSkeleton();
                  }

                  if (viewModel.error != null) {
                    return Center(
                      child: Text(
                        viewModel.error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    );
                  }

                  if (viewModel.files != null) {
                    return WorkFilesList(
                      files: viewModel.files!,
                      onFileTap: (file) async {
                        try {
                          await viewModel.playFile(file, context);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('播放失败: $e')),
                            );
                          }
                        }
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        bottomSheet: const MiniPlayer(),
      ),
    );
  }
}
