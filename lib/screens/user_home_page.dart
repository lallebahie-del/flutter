import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_language.dart';
import '../app_strings.dart';
import '../app_theme_manager.dart';
import 'report_page.dart';
import 'map_page.dart';


class UserHomePage extends StatelessWidget {
  final AppLanguage appLanguage;
  final AppThemeManager themeManager;

  const UserHomePage({
    super.key,
    required this.appLanguage,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.code;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('user_space', lang)),
        actions: [
          // 🌍 MULTI-LANGUE
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: appLanguage.toggle,
          ),

          // 🌙 THEME
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: themeManager.toggleTheme,
          ),

          // 🔓 LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person,
                  size: 90,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.get('welcome_user', lang),
                  style: const TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF386641),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportPage(
                            appLanguage: appLanguage,
                            themeManager: themeManager,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
                    label: const Text(
                      "SIGNALER UN PROBLÈME",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF386641),
                      surfaceTintColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF386641), width: 1.5),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/user-reports');
                    },
                    icon: const Icon(Icons.history_rounded),
                    label: const Text(
                      "MES SIGNALEMENTS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF386641),
                      surfaceTintColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFF386641), width: 1.5),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapPage(
                            appLanguage: appLanguage,
                            themeManager: themeManager,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map_rounded),
                    label: const Text(
                      "VOIR LA CARTE",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
