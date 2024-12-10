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
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
              Strings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text(Strings.home),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到主页
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text(Strings.favorites),
            onTap: () {
              Navigator.pop(context);
              // TODO: 导航到收藏页面
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(Strings.settings),
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
