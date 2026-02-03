import 'package:flutter/material.dart';

import '../widgets/my_drawer.dart';
import '../widgets/settings/setting_item.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsData = [
      {'title': 'Thể Thao', 'color': const Color(0xFFFB8484), 'isActive': true},
      {'title': 'Thời sự', 'color': const Color(0xFF74BDCB), 'isActive': false},
      {
        'title': 'Thể Thao',
        'color': const Color(0xFFFFBD59),
        'isActive': false,
      },
      {'title': 'Thời sự', 'color': const Color(0xFF7B61FF), 'isActive': true},
      {'title': 'Thể Thao', 'color': const Color(0xFFD470FF), 'isActive': true},
      {'title': 'Thời sự', 'color': const Color(0xFFFFC045), 'isActive': false},
      {'title': 'Thể Thao', 'color': const Color(0xFFA5D65A), 'isActive': true},
      {'title': 'Thời sự', 'color': const Color(0xFF8DAAB2), 'isActive': false},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFBA4B),
        centerTitle: true,
        title: const Text(
          'Setting',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
          ),
          itemCount: settingsData.length,
          itemBuilder: (context, index) {
            final item = settingsData[index];
            return SettingItem(
              title: item['title'],
              backgroundColor: item['color'],
              isActive: item['isActive'],
              onTap: () {
                // Handle tap if needed
              },
            );
          },
        ),
      ),
    );
  }
}
