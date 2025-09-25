import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/data/models/my_lists/my_playlists/playlist.dart';
import 'package:asmrapp/presentation/viewmodels/playlist_works_viewmodel.dart';
import 'package:asmrapp/presentation/viewmodels/playlists_viewmodel.dart';
import 'package:asmrapp/widgets/work_grid/enhanced_work_grid_view.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/utils/toast_utils.dart';

class PlaylistWorksView extends StatefulWidget {
  final Playlist playlist;
  final VoidCallback onBack;

  const PlaylistWorksView({
    super.key,
    required this.playlist,
    required this.onBack,
  });

  @override
  State<PlaylistWorksView> createState() => _PlaylistWorksViewState();
}

class _PlaylistWorksViewState extends State<PlaylistWorksView> {
  final WorkLayoutStrategy _layoutStrategy = const WorkLayoutStrategy();
  String? _lastError;

  @override
  Widget build(BuildContext context) {
    final playlistsViewModel = context.read<PlaylistsViewModel>();
    
    return ChangeNotifierProvider(
      create: (_) => PlaylistWorksViewModel(widget.playlist)..loadWorks(),
      child: Consumer<PlaylistWorksViewModel>(
        builder: (context, viewModel, child) {
          // 检查是否有新的错误需要显示 toast
          if (viewModel.error != null && viewModel.error != _lastError) {
            _lastError = viewModel.error;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ToastUtils.showError(context, '加载作品失败: ${viewModel.error}');
            });
          } else if (viewModel.error == null) {
            _lastError = null;
          }

          return Column(
            children: [
              Material(
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: widget.onBack,
                      ),
                      Expanded(
                        child: Text(
                          playlistsViewModel.getDisplayName(widget.playlist.name),
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: EnhancedWorkGridView(
                  works: viewModel.works,
                  isLoading: viewModel.isLoading,
                  error: viewModel.error,
                  onRetry: () => viewModel.refresh(),
                  onRefresh: () => viewModel.refresh(),
                  currentPage: viewModel.currentPage,
                  totalPages: viewModel.totalPages,
                  onPageChanged: (page) => viewModel.loadWorks(page: page),
                  layoutStrategy: _layoutStrategy,
                  emptyMessage: '暂无作品',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 