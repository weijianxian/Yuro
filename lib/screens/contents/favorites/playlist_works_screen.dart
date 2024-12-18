import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/data/models/my_lists/my_playlists/playlist.dart';
import 'package:asmrapp/presentation/viewmodels/playlist_works_viewmodel.dart';

class PlaylistWorksScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistWorksScreen({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlaylistWorksViewModel(playlist),
      child: Scaffold(
        appBar: AppBar(
          title: Text(playlist.name ?? '收藏夹'),
        ),
        body: const Center(
          child: Text('收藏夹作品列表 - 开发中'),
        ),
      ),
    );
  }
}
