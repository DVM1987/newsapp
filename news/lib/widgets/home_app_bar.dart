import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: AppColors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
