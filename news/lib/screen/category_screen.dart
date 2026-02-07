import 'package:flutter/material.dart';

import '../widgets/category/category_app_bar.dart';
import '../widgets/category/category_list.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {'id': 0, 'title': 'Category'};
    final int categoryId = arguments['id'];
    final String categoryTitle = arguments['title'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CategoryAppBar(title: categoryTitle),
      body: CategoryList(categoryId: categoryId, categoryTitle: categoryTitle),
    );
  }
}
