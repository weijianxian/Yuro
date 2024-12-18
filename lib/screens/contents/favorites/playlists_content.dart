import 'package:asmrapp/data/models/my_lists/my_playlists/playlist.dart';
import 'package:flutter/material.dart';
import 'package:asmrapp/screens/contents/favorites/playlist_works_screen.dart';

class PlaylistsContent extends StatefulWidget {
  const PlaylistsContent({super.key});

  @override
  State<PlaylistsContent> createState() => _PlaylistsContentState();
}

class _PlaylistsContentState extends State<PlaylistsContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _onPlaylistTap(BuildContext context, Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistWorksScreen(playlist: playlist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: 1, // 临时，后续从 ViewModel 获取
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.playlist_play),
          title: const Text('默认收藏夹'), // 临时
          subtitle: const Text('0 个作品'), // 临时
        );
      },
    );
  }
}
