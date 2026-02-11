import 'package:flutter/material.dart';

import '../../apps/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool isSearch;
  final VoidCallback? onSearchToggle;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.isSearch = false,
    this.onSearchToggle,
    this.onSearchChanged,
    this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      toolbarHeight: kToolbarHeight * 1.5,
      elevation: 0,
      centerTitle: true,
      title: isSearch
          ? TextField(
              controller: searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm bài viết...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              onChanged: onSearchChanged,
            )
          : (title != null
                ? Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : null),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(
              isSearch ? Icons.arrow_back : Icons.menu,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              if (isSearch) {
                onSearchToggle?.call();
              } else {
                Scaffold.of(context).openDrawer();
              }
            },
          );
        },
      ),
      actions: isSearch
          ? [
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.white, size: 32),
                onPressed: () {
                  searchController?.clear();
                  onSearchChanged?.call('');
                },
              ),
            ]
          : actions ??
                [
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: onSearchToggle,
                  ),
                ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.5);
}
