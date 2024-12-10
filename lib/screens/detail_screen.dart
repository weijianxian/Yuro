import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/models/files/child.dart';
import 'package:asmrapp/widgets/detail/work_cover.dart';
import 'package:asmrapp/widgets/detail/work_info.dart';
import 'package:asmrapp/widgets/detail/work_actions.dart';
import 'package:asmrapp/widgets/detail/work_files_list.dart';
import 'package:asmrapp/widgets/detail/work_files_skeleton.dart';
import 'package:asmrapp/presentation/viewmodels/detail_viewmodel.dart';
import 'package:asmrapp/core/audio/audio_service.dart';
import 'package:asmrapp/core/audio/audio_player.dart';

class DetailScreen extends StatelessWidget {
  final Work work;
  final AudioService _audioService = AudioPlayerService();

  DetailScreen({
    super.key,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailViewModel(work: work)..loadFiles(),
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
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    );
                  }

                  if (viewModel.files != null) {
                    return WorkFilesList(
                      files: viewModel.files!,
                      onFileTap: (file) async {
                        if (file.mediaDownloadUrl == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('无法播放：文件URL不存在')),
                          );
                          return;
                        }
                        
                        try {
                          await _audioService.play(file.mediaDownloadUrl!);
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
        bottomNavigationBar: WorkActions(
          onDownload: () {
            // TODO: 实现下载功能
          },
          onPlay: () async {
            final viewModel = context.read<DetailViewModel>();
            final files = viewModel.files?.children ?? [];
            
            // 查找第一个可播放的文件
            try {
              final playableFile = files.firstWhere(
                (file) => file.type == 'file' && file.mediaDownloadUrl != null,
              );

              if (playableFile.mediaDownloadUrl != null) {
                try {
                  await _audioService.play(playableFile.mediaDownloadUrl!);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('播放失败: $e')),
                    );
                  }
                }
              }
            } catch (e) {
              // 没有找到可播放的文件时会抛出 StateError
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('没有可播放的音频文件')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
