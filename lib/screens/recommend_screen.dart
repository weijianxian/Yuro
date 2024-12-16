import 'package:flutter/material.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/screens/contents/recommend_content.dart';

class RecommendScreen extends StatelessWidget {
  const RecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('为你推荐'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: 实现过滤功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: const RecommendContent(),
    );
  }
} 