import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/playlists_with_exist_statu/playlist.dart';

class PlaylistSelectionDialog extends StatelessWidget {
  final List<Playlist>? playlists;
  final bool isLoading;
  final String? error;
  final Function(Playlist playlist)? onPlaylistTap;
  final VoidCallback? onRetry;

  const PlaylistSelectionDialog({
    super.key,
    this.playlists,
    required this.isLoading,
    this.error,
    this.onPlaylistTap,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '添加到收藏夹',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
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
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('重试'),
              ),
            ],
          ],
        ),
      );
    }

    if (playlists == null || playlists!.isEmpty) {
      return const Center(
        child: Text('暂无收藏夹'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: playlists!.length,
      itemBuilder: (context, index) {
        final playlist = playlists![index];
        return _PlaylistItem(
          playlist: playlist,
          onTap: () => onPlaylistTap?.call(playlist),
        );
      },
    );
  }
}

class _PlaylistItem extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;

  const _PlaylistItem({
    required this.playlist,
    this.onTap,
  });

  String _getDisplayName(String? name) {
    switch (name) {
      case '__SYS_PLAYLIST_MARKED':
        return '我标记的';
      case '__SYS_PLAYLIST_LIKED':
        return '我喜欢的';
      default:
        return name ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_getDisplayName(playlist.name)),
      subtitle: Text('${playlist.worksCount ?? 0} 个作品'),
      trailing: Checkbox(
        value: playlist.exist ?? false,
        onChanged: (_) => onTap?.call(),
      ),
      onTap: onTap,
    );
  }
} 