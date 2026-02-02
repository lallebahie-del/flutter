import 'package:flutter/material.dart';
import '../app_theme_manager.dart';

class ThemeToggle extends StatelessWidget {
  final AppThemeManager themeManager;

  const ThemeToggle({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          themeManager.themeMode == ThemeMode.dark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          color: Colors.white,
          size: 22,
        ),
        onPressed: themeManager.toggleTheme,
        splashRadius: 20,
      ),
    );
  }
}