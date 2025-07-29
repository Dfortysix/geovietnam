import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_progress.dart';
import '../models/province.dart';
import '../data/provinces_data.dart';

class GameProgressService {
  static const String _progressKey = 'game_progress';
  static const String _lastPlayDateKey = 'last_play_date';
  static const String _dailyStreakKey = 'daily_streak';
  static const String _totalScoreKey = 'total_score';
  static const String _unlockedProvincesKey = 'unlocked_provinces';

  // Lấy tiến độ game hiện tại
  static Future<GameProgress> getCurrentProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Lấy danh sách tỉnh
    List<Province> provinces = ProvincesData.getAllProvinces();
    
    // Lấy danh sách tỉnh đã mở khóa
    List<String> unlockedProvinceIds = prefs.getStringList(_unlockedProvincesKey) ?? [];
    
    // Cập nhật trạng thái mở khóa cho các tỉnh
    for (int i = 0; i < provinces.length; i++) {
      if (unlockedProvinceIds.contains(provinces[i].id)) {
        provinces[i] = provinces[i].copyWith(
          isUnlocked: true,
          unlockedDate: DateTime.now(), // Có thể lưu ngày unlock thực tế
        );
      }
    }

    // Lấy thông tin khác
    int totalScore = prefs.getInt(_totalScoreKey) ?? 0;
    int dailyStreak = prefs.getInt(_dailyStreakKey) ?? 0;
    DateTime lastPlayDate = DateTime.parse(
      prefs.getString(_lastPlayDateKey) ?? DateTime.now().toIso8601String()
    );

    return GameProgress(
      provinces: provinces,
      totalScore: totalScore,
      dailyStreak: dailyStreak,
      lastPlayDate: lastPlayDate,
      unlockedProvincesCount: unlockedProvinceIds.length,
      completedDailyChallenges: [], // Có thể mở rộng sau
    );
  }

  // Lưu tiến độ game
  static Future<void> saveProgress(GameProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Lưu thông tin cơ bản
    await prefs.setInt(_totalScoreKey, progress.totalScore);
    await prefs.setInt(_dailyStreakKey, progress.dailyStreak);
    await prefs.setString(_lastPlayDateKey, progress.lastPlayDate.toIso8601String());
    
    // Lưu danh sách tỉnh đã mở khóa
    List<String> unlockedProvinceIds = progress.provinces
        .where((province) => province.isUnlocked)
        .map((province) => province.id)
        .toList();
    await prefs.setStringList(_unlockedProvincesKey, unlockedProvinceIds);
  }

  // Cập nhật điểm số
  static Future<void> updateScore(int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    int currentScore = prefs.getInt(_totalScoreKey) ?? 0;
    await prefs.setInt(_totalScoreKey, currentScore + newScore);
  }

  // Cập nhật daily streak
  static Future<void> updateDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime lastPlayDate = DateTime.parse(
      prefs.getString(_lastPlayDateKey) ?? DateTime.now().toIso8601String()
    );
    int currentStreak = prefs.getInt(_dailyStreakKey) ?? 0;
    
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));
    
    // Kiểm tra xem có chơi hôm qua không
    if (lastPlayDate.year == yesterday.year &&
        lastPlayDate.month == yesterday.month &&
        lastPlayDate.day == yesterday.day) {
      // Tăng streak
      await prefs.setInt(_dailyStreakKey, currentStreak + 1);
    } else if (lastPlayDate.year != today.year ||
               lastPlayDate.month != today.month ||
               lastPlayDate.day != today.day) {
      // Reset streak nếu không chơi liên tục
      await prefs.setInt(_dailyStreakKey, 1);
    }
    
    // Cập nhật ngày chơi cuối
    await prefs.setString(_lastPlayDateKey, today.toIso8601String());
  }

  // Mở khóa tỉnh mới
  static Future<bool> unlockProvince(String provinceId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> unlockedProvinceIds = prefs.getStringList(_unlockedProvincesKey) ?? [];
    
    // Kiểm tra xem tỉnh đã được mở khóa chưa
    if (unlockedProvinceIds.contains(provinceId)) {
      return false; // Đã mở khóa rồi
    }
    
    // Thêm tỉnh vào danh sách đã mở khóa
    unlockedProvinceIds.add(provinceId);
    await prefs.setStringList(_unlockedProvincesKey, unlockedProvinceIds);
    
    return true;
  }

  // Kiểm tra xem có thể mở khóa tỉnh mới không
  static Future<bool> canUnlockNewProvince(int currentScore) async {
    final progress = await getCurrentProgress();
    return progress.canUnlockNewProvince(currentScore);
  }

  // Lấy tỉnh tiếp theo có thể mở khóa
  static Future<Province?> getNextUnlockableProvince() async {
    final progress = await getCurrentProgress();
    return progress.getNextUnlockableProvince();
  }

  // Reset tiến độ game (cho testing)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_lastPlayDateKey);
    await prefs.remove(_dailyStreakKey);
    await prefs.remove(_totalScoreKey);
    await prefs.remove(_unlockedProvincesKey);
  }

  // Lấy thống kê game
  static Future<Map<String, dynamic>> getGameStats() async {
    final progress = await getCurrentProgress();
    
    return {
      'totalProvinces': progress.provinces.length,
      'unlockedProvinces': progress.unlockedCount,
      'completionPercentage': progress.completionPercentage,
      'totalScore': progress.totalScore,
      'dailyStreak': progress.dailyStreak,
      'lastPlayDate': progress.lastPlayDate,
    };
  }

  // Kiểm tra daily challenge
  static Future<bool> isDailyChallengeCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime lastPlayDate = DateTime.parse(
      prefs.getString(_lastPlayDateKey) ?? DateTime.now().toIso8601String()
    );
    
    DateTime today = DateTime.now();
    return lastPlayDate.year == today.year &&
           lastPlayDate.month == today.month &&
           lastPlayDate.day == today.day;
  }

  // Hoàn thành daily challenge
  static Future<void> completeDailyChallenge(int score) async {
    await updateScore(score);
    await updateDailyStreak();
    
    // Kiểm tra xem có thể mở khóa tỉnh mới không
    if (await canUnlockNewProvince(score)) {
      final nextProvince = await getNextUnlockableProvince();
      if (nextProvince != null) {
        await unlockProvince(nextProvince.id);
      }
    }
  }
} 