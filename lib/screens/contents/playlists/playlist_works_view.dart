import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/data/models/my_lists/my_playlists/playlist.dart';
import 'package:asmrapp/presentation/viewmodels/playlist_works_viewmodel.dart';
import 'package:asmrapp/presentation/viewmodels/playlists_viewmodel.dart';
import 'package:asmrapp/widgets/work_grid_view.dart';

class PlaylistWorksView extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onBack;

  const PlaylistWorksView({
    super.key,
    required this.playlist,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final playlistsViewModel = context.read<PlaylistsViewModel>();
    
    return ChangeNotifierProvider(
      create: (_) => PlaylistWorksViewModel(playlist)..loadWorks(),
      child: Consumer<PlaylistWorksViewModel>(
        builder: (context, viewModel, child) {
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
                        onPressed: onBack,
                      ),
                      Expanded(
                        child: Text(
                          playlistsViewModel.getDisplayName(playlist.name),
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: viewModel.isLoading && viewModel.works.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.error != null && viewModel.works.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(viewModel.error!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: viewModel.refresh,
                                  child: const Text('重试'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: viewModel.refresh,
                            child: WorkGridView(
                              works: viewModel.works,
                              isLoading: viewModel.isLoading,
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
} 