import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/news_provider.dart';
import 'screen/category_screen.dart';
import 'screen/favorite_screen.dart';
import 'screen/home_screen.dart';
import 'screen/news_detail_screen.dart';
import 'screen/settings_screen.dart';
import 'screen/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => NewsProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFBA4B)),
          useMaterial3: true,
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (context) => const SplashScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          CategoryScreen.routeName: (context) => const CategoryScreen(),
          FavoriteScreen.routeName: (context) => const FavoriteScreen(),
          NewsDetailScreen.routeName: (context) => const NewsDetailScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
