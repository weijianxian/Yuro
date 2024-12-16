import 'package:flutter/material.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/screens/contents/popular_content.dart';

class PopularScreen extends StatelessWidget {
  const PopularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('热门作品'),
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
      body: const PopularContent(),
    );
  }
} 