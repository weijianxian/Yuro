import 'package:flutter/material.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/common/constants/strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: Strings.search,
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: Center(
        child: Text(Strings.musicList),
      ),
    );
  }
} 