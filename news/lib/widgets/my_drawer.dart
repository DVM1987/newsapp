// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../apps/constants/app_colors.dart';
import '../apps/routers/router_name.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF686868);
    const Color activeColor = AppColors.primary;
    const Color whiteColor = AppColors.white;

    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: bgColor,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Logo Section
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/Ellipse.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'App Tin Tức',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        offset: const Offset(2, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            // Menu Items
            _buildDrawerItem(
              context: context,
              title: 'Trang Chủ',
              color: currentRoute == RouterName.home ? activeColor : whiteColor,
              onTap: () {
                Navigator.of(context).pushReplacementNamed(RouterName.home);
              },
            ),
            _buildDrawerItem(
              context: context,
              title: 'Yêu Thích',
              color: currentRoute == RouterName.favorites
                  ? activeColor
                  : whiteColor,
              onTap: () {
                Navigator.of(
                  context,
                ).pushReplacementNamed(RouterName.favorites);
              },
            ),
            _buildDrawerItem(
              context: context,
              title: 'Setting',
              color: currentRoute == RouterName.settings
                  ? activeColor
                  : whiteColor,
              onTap: () {
                Navigator.of(context).pushReplacementNamed(RouterName.settings);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: color,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(1, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
