import 'package:flutter/material.dart';
import 'lib/services/game_progress_service.dart';
import 'lib/services/google_play_games_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== BẮT ĐẦU TEST HỆ THỐNG LƯU TIẾN TRÌNH ===');
  
  // Test 1: Kiểm tra trạng thái đăng nhập
  final gamesService = GooglePlayGamesService();
  print('User đã đăng nhập: ${gamesService.isSignedIn}');
  
  // Test 2: Debug tiến độ hiện tại
  await GameProgressService.debugCurrentProgress();
  
  // Test 3: Chạy test hệ thống
  await GameProgressService.testUserProgress();
  
  print('=== KẾT THÚC TEST ===');
} 