import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../apps/routers/router_name.dart';
import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newsProvider = Provider.of<NewsProvider>(context, listen: false);

      // Sync user ID if logged in
      if (authProvider.isLoggedIn) {
        newsProvider.setUserId(authProvider.userId);
      }

      Navigator.pushReplacementNamed(context, RouterName.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFBA4B),
      body: Center(
        child: Text(
          'News',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
