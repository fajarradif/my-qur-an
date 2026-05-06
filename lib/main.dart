import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyQuranApp());
}

class MyQuranApp extends StatelessWidget {
  const MyQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyQuran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Desain baru ini dikhususkan untuk tampilan terang/bersih (Light Mode) 
      // yang memadukan Hijau Tua dan Emas
      themeMode: ThemeMode.light, 
      home: const HomeScreen(),
    );
  }
}
