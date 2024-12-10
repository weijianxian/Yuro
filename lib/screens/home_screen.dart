import 'package:flutter/material.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ASMR Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: const Center(
        child: Text('音乐列表将在这里显示'),
      ),
    );
  }
} 