import 'package:flutter/material.dart';

import '../widgets/category/category_app_bar.dart';
import '../widgets/category/category_list.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String categoryTitle =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Category';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CategoryAppBar(title: categoryTitle),
      body: CategoryList(category: categoryTitle),
    );
  }
}
