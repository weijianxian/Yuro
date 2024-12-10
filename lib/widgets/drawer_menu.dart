import 'package:flutter/material.dart';
import 'package:asmrapp/common/constants/strings.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              Strings.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(Strings.home),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到主页
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(Strings.favorites),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到收藏页面
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(Strings.settings),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到设置页面
            },
          ),
        ],
      ),
    );
  }
} 