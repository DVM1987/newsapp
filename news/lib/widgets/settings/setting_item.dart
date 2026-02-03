import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final bool isActive;
  final VoidCallback onTap;

  const SettingItem({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: isActive
                  ? Center(
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00A3FF),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
