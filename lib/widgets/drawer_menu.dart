import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'package:asmrapp/presentation/viewmodels/auth_viewmodel.dart';
import 'package:asmrapp/presentation/widgets/auth/login_dialog.dart';
import 'package:asmrapp/screens/favorites_screen.dart';
import 'package:asmrapp/screens/recommend_screen.dart';
import 'package:asmrapp/screens/settings/cache_manager_screen.dart';
import 'package:asmrapp/screens/popular_screen.dart';
import 'package:asmrapp/core/theme/theme_controller.dart';

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
          ListTile(
            leading: const Icon(Icons.trending_up),
            title: const Text('热门作品'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PopularScreen(),
                ),
              );
            },
          ),
            Divider(
              color: Theme.of(context).colorScheme.surfaceVariant,
              height: 1,
            ),
          Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return ListTile(
                leading: Icon(_getThemeIcon(themeController.themeMode)),
                title: Text(_getThemeText(themeController.themeMode)),
                onTap: () => themeController.toggleThemeMode(),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_high;
      case ThemeMode.dark:
        return Icons.brightness_2;
    }
  }

  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统主题';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }
}
