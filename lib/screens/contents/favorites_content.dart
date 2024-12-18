import 'package:flutter/material.dart';

class FavoritesContent extends StatefulWidget {
  const FavoritesContent({super.key});

  @override
  State<FavoritesContent> createState() => _FavoritesContentState();
}

class _FavoritesContentState extends State<FavoritesContent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Center(
      child: Text('收藏列表 - 开发中'),
    );
  }
} 