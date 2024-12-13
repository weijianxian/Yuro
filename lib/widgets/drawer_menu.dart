import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'package:asmrapp/presentation/viewmodels/auth_viewmodel.dart';
import 'package:asmrapp/presentation/widgets/auth/login_dialog.dart';
import 'package:asmrapp/screens/favorites_screen.dart';
import 'package:asmrapp/screens/recommend_screen.dart';
import 'package:asmrapp/screens/settings/cache_manager_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LoginDialog(),
    );
  }

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
            },
          ),
          Consumer<AuthViewModel>(
            builder: (context, authVM, _) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  authVM.isLoggedIn ? authVM.username ?? '' : '登录',
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (authVM.isLoggedIn) {
                    authVM.logout();
                  } else {
                    _showLoginDialog(context);
                  }
                },
              );
            },
          ),
          Consumer<AuthViewModel>(
            builder: (context, authVM, _) {
              return ListTile(
                leading: const Icon(Icons.recommend),
                title: const Text('为你推荐'),
                onTap: () {
                  Navigator.pop(context);
                  if (!authVM.isLoggedIn) {
                    _showLoginDialog(context);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendScreen(),
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text(Strings.favorites),
            onTap: () {
              Navigator.pop(context);
              // 检查用户是否已登录
              final authVM = context.read<AuthViewModel>();
              if (!authVM.isLoggedIn) {
                // 如果未登录，显示登录对话框
                _showLoginDialog(context);
                return;
              }
              // 导航到收藏页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
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
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('缓存管理'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CacheManagerScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
