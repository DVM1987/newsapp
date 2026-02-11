import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'apps/routers/router_name.dart';
import 'providers/auth_provider.dart';
import 'providers/news_provider.dart';
import 'providers/settings_provider.dart';
import 'screen/category_screen.dart';
import 'screen/change_password_screen.dart';
import 'screen/favorite_screen.dart';
import 'screen/home_screen.dart';
import 'screen/login_screen.dart';
import 'screen/news_detail_screen.dart';
import 'screen/settings_screen.dart';
import 'screen/splash_screen.dart';
import 'screen/web_view_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => NewsProvider()),
        ChangeNotifierProvider(create: (ctx) => SettingsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFBA4B)),
          useMaterial3: true,
        ),
        initialRoute: RouterName.splash,
        routes: {
          RouterName.splash: (context) => const SplashScreen(),
          RouterName.login: (context) => const LoginScreen(),
          RouterName.home: (context) => const HomeScreen(),
          RouterName.category: (context) => const CategoryScreen(),
          RouterName.favorites: (context) => const FavoriteScreen(),
          RouterName.newsDetail: (context) => const NewsDetailScreen(),
          RouterName.settings: (context) => const SettingsScreen(),
          RouterName.changePassword: (context) => const ChangePasswordScreen(),
          RouterName.webView: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return WebViewScreen(
              url: args['url'] as String,
              title: args['title'] as String? ?? 'Web Page',
            );
          },
        },
      ),
    );
  }
}
