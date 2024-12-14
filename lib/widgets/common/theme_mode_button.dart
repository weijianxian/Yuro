import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/core/theme/theme_controller.dart';

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  IconData _getIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_high;
      case ThemeMode.dark:
        return Icons.brightness_2;
    }
  }

  String _getTooltip(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return IconButton(
          icon: Icon(_getIcon(themeController.themeMode)),
          tooltip: _getTooltip(themeController.themeMode),
          onPressed: () => themeController.toggleThemeMode(),
        );
      },
    );
  }
} 