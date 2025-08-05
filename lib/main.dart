import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/google_play_games_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp();
  
  // Khởi tạo Google Play Games Services
  await GooglePlayGamesService().initialize();
  
  runApp(const GeoVietnamApp());
}

class GeoVietnamApp extends StatelessWidget {
  const GeoVietnamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<GooglePlayGamesService>(
      create: (_) => GooglePlayGamesService(),
      child: MaterialApp(
        title: 'GeoVietnam - Game Địa Lý Việt Nam',
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
