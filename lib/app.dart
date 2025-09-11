import 'package:flutter/material.dart';
import 'package:totheblessing/core/config/app_pages.dart';
import 'package:totheblessing/core/config/app_routes.dart';
import 'package:totheblessing/listen_deep_links.dart';
import 'package:totheblessing/main.dart';
import 'package:uni_links/uni_links.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Meu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppPages.onGenerateRoute,
    );
  }
}
