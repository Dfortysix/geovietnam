import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GeoVietnamApp());
}

class GeoVietnamApp extends StatelessWidget {
  const GeoVietnamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoVietnam - Game Địa Lý Việt Nam',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
