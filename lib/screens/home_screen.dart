import 'package:flutter/material.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'package:asmrapp/screens/search_screen.dart';
import 'package:asmrapp/screens/contents/home_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.appName),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: const HomeContent(),
    );
  }
}
