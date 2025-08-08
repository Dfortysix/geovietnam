import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_progress.dart';
import '../models/province.dart';
import '../data/provinces_data.dart';
import 'user_service.dart';
import 'google_play_games_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameProgressService {
  static const String _progressKey = 'game_progress';
  static const String _lastPlayDateKey = 'last_play_date';
  static const String _dailyStreakKey = 'daily_streak';
  static const String _totalScoreKey = 'total_score';
  static const String _unlockedProvincesKey = 'unlocked_provinces';

  static final UserService _userService = UserService();

  // Lấy tiến độ game hiện tại (ưu tiên Firestore nếu user đã đăng nhập)
  static Future<GameProgress> getCurrentProgress() async {
    final gamesService = GooglePlayGamesService();
    
    // Nếu user đã đăng nhập, lấy từ Firestore
    if (gamesService.isSignedIn && gamesService.currentUser != null) {
      try {
        final cloudProgress = await _userService.getCompleteGameProgress(gamesService.currentUser!.id);
        if (cloudProgress != null) {
          // Đồng bộ với local storage
          await _saveToLocalStorage(cloudProgress);
          return cloudProgress;
        }
      } catch (e) {
        // Fallback to local storage
      }
    }
    
    // Lấy từ local storage
    return _getLocalProgress();
  }

  // Lấy tiến độ từ local storage
  static Future<GameProgress> _getLocalProgress() async {
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
          unlockedDate: DateTime.now(),
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
      completedDailyChallenges: [],
    );
  }

  // Lưu tiến độ game (cả local và cloud)
  static Future<void> saveProgress(GameProgress progress) async {
    // Lưu local storage
    await _saveToLocalStorage(progress);
    
    // Lưu cloud nếu user đã đăng nhập
    final gamesService = GooglePlayGamesService();
    if (gamesService.isSignedIn && gamesService.currentUser != null) {
      try {
        await _userService.saveGameProgress(gamesService.currentUser!.id, progress);
        await _userService.saveAllProvinces(gamesService.currentUser!.id, progress.provinces);
      } catch (e) {
        // Ignore cloud save error
      }
    }
  }

  // Lưu vào local storage
  static Future<void> _saveToLocalStorage(GameProgress progress) async {
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
    int updatedScore = currentScore + newScore;
    
    // Cập nhật local
    await prefs.setInt(_totalScoreKey, updatedScore);
    
    // Cập nhật cloud nếu user đã đăng nhập
    final gamesService = GooglePlayGamesService();
    if (gamesService.isSignedIn && gamesService.currentUser != null) {
      try {
        await _userService.updateTotalScore(gamesService.currentUser!.id, updatedScore);
      } catch (e) {
        // Ignore cloud update error
      }
    }
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
    
    int newStreak = currentStreak;
    
    // Kiểm tra xem có chơi hôm qua không
    if (lastPlayDate.year == yesterday.year &&
        lastPlayDate.month == yesterday.month &&
        lastPlayDate.day == yesterday.day) {
      // Tăng streak
      newStreak = currentStreak + 1;
    } else if (lastPlayDate.year != today.year ||
               lastPlayDate.month != today.month ||
               lastPlayDate.day != today.day) {
      // Reset streak nếu không chơi liên tục
      newStreak = 1;
    }
    
    // Cập nhật local
    await prefs.setInt(_dailyStreakKey, newStreak);
    await prefs.setString(_lastPlayDateKey, today.toIso8601String());
    
    // Cập nhật cloud nếu user đã đăng nhập
    final gamesService = GooglePlayGamesService();
    if (gamesService.isSignedIn && gamesService.currentUser != null) {
      try {
        await _userService.updateDailyStreak(gamesService.currentUser!.id, newStreak);
      } catch (e) {
        // Ignore cloud update error
      }
    }
  }

  // Mở khóa tỉnh mới
  static Future<void> unlockProvince(String provinceId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> unlockedProvinceIds = prefs.getStringList(_unlockedProvincesKey) ?? [];
    
    if (!unlockedProvinceIds.contains(provinceId)) {
      unlockedProvinceIds.add(provinceId);
      await prefs.setStringList(_unlockedProvincesKey, unlockedProvinceIds);
      // Cập nhật cloud nếu user đã đăng nhập
      final gamesService = GooglePlayGamesService();
      if (gamesService.isSignedIn && gamesService.currentUser != null) {
        try {
          await _userService.unlockProvince(gamesService.currentUser!.id, provinceId);
        } catch (e) {
          // Ignore cloud update error
        }
      }
    }
  }



  // Cập nhật điểm số cho tỉnh
  static Future<void> updateProvinceScore(String provinceId, int score) async {
    // Cập nhật cloud nếu user đã đăng nhập
    final gamesService = GooglePlayGamesService();
    if (gamesService.isSignedIn && gamesService.currentUser != null) {
      try {
        await _userService.updateProvinceScore(gamesService.currentUser!.id, provinceId, score);
      } catch (e) {
        // Ignore cloud update error
      }
    }
  }

  // Đánh dấu tỉnh đã khám phá
  static Future<void> exploreProvince(String provinceId) async {
    // Cập nhật cloud nếu user đã đăng nhập
    final gamesService = GooglePlayGamesService();
    if (gamesService.isSignedIn && gamesService.currentUser != null) {
      try {
        await _userService.exploreProvince(gamesService.currentUser!.id, provinceId);
      } catch (e) {
        // Ignore cloud update error
      }
    }
  }

  // Thêm daily challenge đã hoàn thành
  static Future<void> addCompletedDailyChallenge(String challengeId) async {
    // Cập nhật cloud nếu user đã đăng nhập
    final gamesService = GooglePlayGamesService();
    if (gamesService.isSignedIn && gamesService.currentUser != null) {
      try {
        await _userService.addCompletedDailyChallenge(gamesService.currentUser!.id, challengeId);
      } catch (e) {
        // Ignore cloud update error
      }
    }
  }

  // Hoàn thành daily challenge: lưu điểm, streak, daily challenge, mở khóa tỉnh nếu đủ điểm
  static Future<void> completeDailyChallenge(int score) async {
    await updateScore(score);
    await updateDailyStreak();
    // Có thể thêm logic lưu challengeId nếu cần
  }

  // Lấy tỉnh tiếp theo có thể mở khóa
  static Future<Province?> getNextUnlockableProvince() async {
    final progress = await getCurrentProgress();
    return progress.getNextUnlockableProvince();
  }

  // Đồng bộ dữ liệu từ cloud về local
  static Future<void> syncFromCloud() async {
    final gamesService = GooglePlayGamesService();
    if (gamesService.isSignedIn && gamesService.currentUser != null) {
      try {
        final cloudProgress = await _userService.getCompleteGameProgress(gamesService.currentUser!.id);
        if (cloudProgress != null) {
          await _saveToLocalStorage(cloudProgress);
        }
      } catch (e) {
        // Ignore sync error
      }
    }
  }

  // Đồng bộ dữ liệu từ local lên cloud
  static Future<void> syncToCloud() async {
    final gamesService = GooglePlayGamesService();
    if (gamesService.isSignedIn && gamesService.currentUser != null) {
      try {
        final localProgress = await _getLocalProgress();
        await _userService.saveGameProgress(gamesService.currentUser!.id, localProgress);
        await _userService.saveAllProvinces(gamesService.currentUser!.id, localProgress.provinces);
      } catch (e) {
        // Ignore sync error
      }
    }
  }
} 