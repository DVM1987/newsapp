import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CategoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CategoryAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: false,
      titleSpacing: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.5);
}
