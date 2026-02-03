import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      toolbarHeight: kToolbarHeight * 1.5,
      elevation: 0,
      centerTitle: true,
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w400,
              ),
            )
          : null,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 32),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 32),
              onPressed: () {
                // Future: Implement search
              },
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.5);
}
