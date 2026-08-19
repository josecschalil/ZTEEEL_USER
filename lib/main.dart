import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ZteelApp());
}

class ZteelApp extends StatelessWidget {
  const ZteelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zteel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orangeWarm),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
