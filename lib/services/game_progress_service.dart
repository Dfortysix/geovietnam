import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_progress.dart';
import '../models/province.dart';
import '../data/provinces_data.dart';
import 'user_service.dart';
import 'google_play_games_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameProgressService {
  static const String _progressKey = 'game_progress';
  static const String _lastPlayDateKey = 'last_play_date';
  static const String _dailyStreakKey = 'daily_streak';
  static const String _totalScoreKey = 'total_score';
  static const String _unlockedProvincesKey = 'unlocked_provinces';

  static final UserService _userService = UserService();

  // Lấy Firebase Auth UID của user hiện tại
  static String? get _currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Lấy tiến độ game hiện tại (ưu tiên local storage, sau đó sync với cloud)
  static Future<GameProgress> getCurrentProgress() async {
    final userId = _currentUserId;
    
    // Luôn lấy từ local storage trước
    final localProgress = await _getLocalProgress(userId);
    
    // Nếu user đã đăng nhập, thử sync với cloud
    if (userId != null) {
      try {
        final cloudProgress = await _userService.getCompleteGameProgress(userId);
        if (cloudProgress != null) {
          // Merge cloud data với local data (ưu tiên cloud cho các trường quan trọng)
          final mergedProgress = _mergeProgress(localProgress, cloudProgress);
          // Lưu merged data về local
          await _saveToLocalStorage(mergedProgress, userId);
          return mergedProgress;
        }
      } catch (e) {
        // Nếu không lấy được từ cloud, sử dụng local data
        print('Cloud sync failed, using local data: $e');
      }
    }
    
    return localProgress;
  }

  // Merge local và cloud progress (ưu tiên cloud cho score và unlocked provinces)
  static GameProgress _mergeProgress(GameProgress local, GameProgress cloud) {
    // Tạo map của provinces từ local
    final Map<String, Province> localProvincesMap = {
      for (var p in local.provinces) p.id: p
    };
    
    // Merge với cloud provinces
    final List<Province> mergedProvinces = cloud.provinces.map((cloudProvince) {
      final localProvince = localProvincesMap[cloudProvince.id];
      if (localProvince != null) {
        // Merge: ưu tiên cloud cho isUnlocked, isExplored, score
        return localProvince.copyWith(
          isUnlocked: cloudProvince.isUnlocked || localProvince.isUnlocked,
          isExplored: cloudProvince.isExplored || localProvince.isExplored,
          score: cloudProvince.score > localProvince.score ? cloudProvince.score : localProvince.score,
        );
      }
      return cloudProvince;
    }).toList();
    
    // Thêm provinces chỉ có trong local
    for (final localProvince in local.provinces) {
      if (!mergedProvinces.any((p) => p.id == localProvince.id)) {
        mergedProvinces.add(localProvince);
      }
    }
    
    return GameProgress(
      provinces: mergedProvinces,
      totalScore: cloud.totalScore > local.totalScore ? cloud.totalScore : local.totalScore,
      dailyStreak: cloud.dailyStreak > local.dailyStreak ? cloud.dailyStreak : local.dailyStreak,
      lastPlayDate: cloud.lastPlayDate.isAfter(local.lastPlayDate) ? cloud.lastPlayDate : local.lastPlayDate,
      unlockedProvincesCount: mergedProvinces.where((p) => p.isUnlocked).length,
      completedDailyChallenges: [...local.completedDailyChallenges, ...cloud.completedDailyChallenges].toSet().toList(),
    );
  }

  // Lấy tiến độ từ local storage theo user
  static Future<GameProgress> _getLocalProgress(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Tạo key riêng cho từng user
    final userPrefix = userId ?? 'anonymous';
    final userUnlockedKey = '${userPrefix}_$_unlockedProvincesKey';
    final userTotalScoreKey = '${userPrefix}_$_totalScoreKey';
    final userDailyStreakKey = '${userPrefix}_$_dailyStreakKey';
    final userLastPlayDateKey = '${userPrefix}_$_lastPlayDateKey';
    final userExploredKey = '${userPrefix}_explored_provinces';
    
    // Lấy danh sách tỉnh
    List<Province> provinces = ProvincesData.getAllProvinces();
    
    // Lấy danh sách tỉnh đã mở khóa và đã khám phá
    List<String> unlockedProvinceIds = prefs.getStringList(userUnlockedKey) ?? [];
    List<String> exploredProvinceIds = prefs.getStringList(userExploredKey) ?? [];
    
    // Cập nhật trạng thái cho các tỉnh
    for (int i = 0; i < provinces.length; i++) {
      final province = provinces[i];
      bool isUnlocked = unlockedProvinceIds.contains(province.id);
      bool isExplored = exploredProvinceIds.contains(province.id);
      
      // Lấy score của province từ local storage
      final provinceScoreKey = '${userPrefix}_province_score_${province.id}';
      int provinceScore = prefs.getInt(provinceScoreKey) ?? 0;
      
      provinces[i] = province.copyWith(
        isUnlocked: isUnlocked,
        isExplored: isExplored,
        score: provinceScore,
        unlockedDate: isUnlocked ? DateTime.now() : null,
      );
    }

    // Lấy thông tin khác
    int totalScore = prefs.getInt(userTotalScoreKey) ?? 0;
    int dailyStreak = prefs.getInt(userDailyStreakKey) ?? 0;
    DateTime lastPlayDate = DateTime.parse(
      prefs.getString(userLastPlayDateKey) ?? DateTime.now().toIso8601String()
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
    final userId = _currentUserId;
    
    // Lưu local storage theo user
    await _saveToLocalStorage(progress, userId);
    
    // Lưu cloud nếu user đã đăng nhập
    if (userId != null) {
      try {
        await _userService.saveGameProgress(userId, progress);
        await _userService.saveAllProvinces(userId, progress.provinces);
      } catch (e) {
        // Ignore cloud save error
      }
    }
  }

  // Lưu vào local storage theo user
  static Future<void> _saveToLocalStorage(GameProgress progress, String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Tạo key riêng cho từng user
    final userPrefix = userId ?? 'anonymous';
    final userUnlockedKey = '${userPrefix}_$_unlockedProvincesKey';
    final userTotalScoreKey = '${userPrefix}_$_totalScoreKey';
    final userDailyStreakKey = '${userPrefix}_$_dailyStreakKey';
    final userLastPlayDateKey = '${userPrefix}_$_lastPlayDateKey';
    final userExploredKey = '${userPrefix}_explored_provinces';
    
    // Lưu thông tin cơ bản
    await prefs.setInt(userTotalScoreKey, progress.totalScore);
    await prefs.setInt(userDailyStreakKey, progress.dailyStreak);
    await prefs.setString(userLastPlayDateKey, progress.lastPlayDate.toIso8601String());
    
    // Lưu danh sách tỉnh đã mở khóa
    List<String> unlockedProvinceIds = progress.provinces
        .where((province) => province.isUnlocked)
        .map((province) => province.id)
        .toList();
    await prefs.setStringList(userUnlockedKey, unlockedProvinceIds);
    
    // Lưu danh sách tỉnh đã khám phá
    List<String> exploredProvinceIds = progress.provinces
        .where((province) => province.isExplored)
        .map((province) => province.id)
        .toList();
    await prefs.setStringList(userExploredKey, exploredProvinceIds);
    
    // Lưu score của từng tỉnh
    for (final province in progress.provinces) {
      if (province.score > 0) {
        final provinceScoreKey = '${userPrefix}_province_score_${province.id}';
        await prefs.setInt(provinceScoreKey, province.score);
      }
    }
  }

  // Cập nhật điểm số
  static Future<void> updateScore(int newScore) async {
    final userId = _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    
    // Tạo key riêng cho từng user
    final userPrefix = userId ?? 'anonymous';
    final userTotalScoreKey = '${userPrefix}_$_totalScoreKey';
    
    int currentScore = prefs.getInt(userTotalScoreKey) ?? 0;
    int updatedScore = currentScore + newScore;
    
    // Cập nhật local
    await prefs.setInt(userTotalScoreKey, updatedScore);
    
    // Cập nhật cloud nếu user đã đăng nhập
    if (userId != null) {
      try {
        await _userService.updateTotalScore(userId, updatedScore);
      } catch (e) {
        // Ignore cloud update error
      }
    }
  }

  // Cập nhật daily streak
  static Future<void> updateDailyStreak() async {
    final userId = _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    
    // Tạo key riêng cho từng user
    final userPrefix = userId ?? 'anonymous';
    final userDailyStreakKey = '${userPrefix}_$_dailyStreakKey';
    final userLastPlayDateKey = '${userPrefix}_$_lastPlayDateKey';
    
    DateTime lastPlayDate = DateTime.parse(
      prefs.getString(userLastPlayDateKey) ?? DateTime.now().toIso8601String()
    );
    int currentStreak = prefs.getInt(userDailyStreakKey) ?? 0;
    
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
    await prefs.setInt(userDailyStreakKey, newStreak);
    await prefs.setString(userLastPlayDateKey, today.toIso8601String());
    
    // Cập nhật cloud nếu user đã đăng nhập
    if (userId != null) {
      try {
        await _userService.updateDailyStreak(userId, newStreak);
      } catch (e) {
        // Ignore cloud update error
      }
    }
  }

  // Mở khóa tỉnh mới
  static Future<void> unlockProvince(String provinceId) async {
    final userId = _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    
    // Tạo key riêng cho từng user
    final userPrefix = userId ?? 'anonymous';
    final userUnlockedKey = '${userPrefix}_$_unlockedProvincesKey';
    
    List<String> unlockedProvinceIds = prefs.getStringList(userUnlockedKey) ?? [];
    
    if (!unlockedProvinceIds.contains(provinceId)) {
      unlockedProvinceIds.add(provinceId);
      await prefs.setStringList(userUnlockedKey, unlockedProvinceIds);
      
      // Cập nhật cloud nếu user đã đăng nhập
      if (userId != null) {
        try {
          await _userService.unlockProvince(userId, provinceId);
        } catch (e) {
          // Ignore cloud update error
        }
      }
    }
  }

  // Cập nhật điểm số cho tỉnh
  static Future<void> updateProvinceScore(String provinceId, int score) async {
    final userId = _currentUserId;
    
    // Cập nhật local storage
    final prefs = await SharedPreferences.getInstance();
    final userPrefix = userId ?? 'anonymous';
    final userUnlockedKey = '${userPrefix}_$_unlockedProvincesKey';
    
    // Lấy danh sách tỉnh hiện tại
    List<String> unlockedProvinceIds = prefs.getStringList(userUnlockedKey) ?? [];
    
    // Cập nhật local storage với score mới
    // Lưu score vào một key riêng cho province
    final provinceScoreKey = '${userPrefix}_province_score_$provinceId';
    await prefs.setInt(provinceScoreKey, score);
    
    // Cập nhật cloud nếu user đã đăng nhập
    if (userId != null) {
      try {
        await _userService.updateProvinceScore(userId, provinceId, score);
      } catch (e) {
        // Ignore cloud update error
      }
    }
  }

  // Đánh dấu tỉnh đã khám phá
  static Future<void> exploreProvince(String provinceId) async {
    final userId = _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    
    // Tạo key riêng cho từng user
    final userPrefix = userId ?? 'anonymous';
    final userExploredKey = '${userPrefix}_explored_provinces';
    
    // Lấy danh sách tỉnh đã khám phá
    List<String> exploredProvinceIds = prefs.getStringList(userExploredKey) ?? [];
    
    // Thêm vào danh sách nếu chưa có
    if (!exploredProvinceIds.contains(provinceId)) {
      exploredProvinceIds.add(provinceId);
      await prefs.setStringList(userExploredKey, exploredProvinceIds);
    }
    
    // Cập nhật cloud nếu user đã đăng nhập
    if (userId != null) {
      try {
        await _userService.exploreProvince(userId, provinceId);
      } catch (e) {
        // Ignore cloud update error
      }
    }
  }

  // Thêm daily challenge đã hoàn thành
  static Future<void> addCompletedDailyChallenge(String challengeId) async {
    final userId = _currentUserId;
    
    // Cập nhật cloud nếu user đã đăng nhập
    if (userId != null) {
      try {
        await _userService.addCompletedDailyChallenge(userId, challengeId);
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
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final cloudProgress = await _userService.getCompleteGameProgress(userId);
        if (cloudProgress != null) {
          await _saveToLocalStorage(cloudProgress, userId);
        }
      } catch (e) {
        // Ignore sync error
      }
    }
  }

  // Đồng bộ dữ liệu từ local lên cloud
  static Future<void> syncToCloud() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final localProgress = await _getLocalProgress(userId);
        await _userService.saveGameProgress(userId, localProgress);
        await _userService.saveAllProvinces(userId, localProgress.provinces);
      } catch (e) {
        // Ignore sync error
      }
    }
  }

  // Debug: In thông tin tiến độ hiện tại
  static Future<void> debugCurrentProgress() async {
    final userId = _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    
    print('=== DEBUG CURRENT PROGRESS ===');
    print('User ID: $userId');
    print('Firebase Auth Current User: ${FirebaseAuth.instance.currentUser?.uid}');
    print('Firebase Auth Email: ${FirebaseAuth.instance.currentUser?.email}');
    
    if (userId != null) {
      final userPrefix = userId;
      final userUnlockedKey = '${userPrefix}_$_unlockedProvincesKey';
      final userTotalScoreKey = '${userPrefix}_$_totalScoreKey';
      final userDailyStreakKey = '${userPrefix}_$_dailyStreakKey';
      final userExploredKey = '${userPrefix}_explored_provinces';
      
      final unlockedProvinces = prefs.getStringList(userUnlockedKey) ?? [];
      final totalScore = prefs.getInt(userTotalScoreKey) ?? 0;
      final dailyStreak = prefs.getInt(userDailyStreakKey) ?? 0;
      final exploredProvinces = prefs.getStringList(userExploredKey) ?? [];
      
      print('Unlocked Provinces: $unlockedProvinces');
      print('Total Score: $totalScore');
      print('Daily Streak: $dailyStreak');
      print('Explored Provinces: $exploredProvinces');
      
      // In score của từng tỉnh
      for (final provinceId in unlockedProvinces) {
        final provinceScoreKey = '${userPrefix}_province_score_$provinceId';
        final score = prefs.getInt(provinceScoreKey) ?? 0;
        print('Province $provinceId Score: $score');
      }
    } else {
      print('User not logged in');
    }
    print('=============================');
  }

  // Debug: In tất cả dữ liệu trong SharedPreferences
  static Future<void> debugAllLocalStorage() async {
    final userId = _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    
    print('=== DEBUG ALL LOCAL STORAGE ===');
    print('User ID: $userId');
    print('Firebase Auth Current User: ${FirebaseAuth.instance.currentUser?.uid}');
    
    // Lấy tất cả keys
    final allKeys = prefs.getKeys();
    print('Total keys in SharedPreferences: ${allKeys.length}');
    
    // Phân loại keys theo user
    final userPrefix = userId ?? 'anonymous';
    final userKeys = allKeys.where((key) => key.startsWith(userPrefix)).toList();
    final otherKeys = allKeys.where((key) => !key.startsWith(userPrefix)).toList();
    
    print('\n--- USER KEYS (${userKeys.length}) ---');
    for (final key in userKeys) {
      final value = prefs.get(key);
      print('$key: $value');
    }
    
    print('\n--- OTHER KEYS (${otherKeys.length}) ---');
    for (final key in otherKeys) {
      final value = prefs.get(key);
      print('$key: $value');
    }
    
    // In chi tiết từng loại dữ liệu
    if (userId != null) {
      print('\n--- DETAILED USER DATA ---');
      
      // Total Score
      final totalScoreKey = '${userPrefix}_$_totalScoreKey';
      final totalScore = prefs.getInt(totalScoreKey);
      print('Total Score Key: $totalScoreKey = $totalScore');
      
      // Daily Streak
      final dailyStreakKey = '${userPrefix}_$_dailyStreakKey';
      final dailyStreak = prefs.getInt(dailyStreakKey);
      print('Daily Streak Key: $dailyStreakKey = $dailyStreak');
      
      // Last Play Date
      final lastPlayDateKey = '${userPrefix}_$_lastPlayDateKey';
      final lastPlayDate = prefs.getString(lastPlayDateKey);
      print('Last Play Date Key: $lastPlayDateKey = $lastPlayDate');
      
      // Unlocked Provinces
      final unlockedKey = '${userPrefix}_$_unlockedProvincesKey';
      final unlockedProvinces = prefs.getStringList(unlockedKey);
      print('Unlocked Provinces Key: $unlockedKey = $unlockedProvinces');
      
      // Explored Provinces
      final exploredKey = '${userPrefix}_explored_provinces';
      final exploredProvinces = prefs.getStringList(exploredKey);
      print('Explored Provinces Key: $exploredKey = $exploredProvinces');
      
      // Province Scores
      final provinceScoreKeys = userKeys.where((key) => key.contains('province_score_')).toList();
      print('\n--- PROVINCE SCORES (${provinceScoreKeys.length}) ---');
      for (final key in provinceScoreKeys) {
        final score = prefs.getInt(key);
        print('$key: $score');
      }
    }
    
    print('=== END DEBUG ALL LOCAL STORAGE ===');
  }

  // Test Firestore connection và permissions
  static Future<void> testFirestoreConnection() async {
    print('=== TESTING FIRESTORE CONNECTION ===');
    
    final userId = _currentUserId;
    print('Current User ID: $userId');
    print('Firebase Auth Current User: ${FirebaseAuth.instance.currentUser?.uid}');
    print('Firebase Auth Email: ${FirebaseAuth.instance.currentUser?.email}');
    
    if (userId == null) {
      print('❌ No user logged in');
      return;
    }
    
    try {
      // Test 1: Đọc user document
      print('Testing read user document...');
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      print('✅ User document read successful: ${userDoc.exists}');
      
      // Test 2: Ghi test data
      print('Testing write test data...');
      await FirebaseFirestore.instance.collection('test').doc('test_${DateTime.now().millisecondsSinceEpoch}').set({
        'test': true,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Test write successful');
      
      // Test 3: Ghi user profile
      print('Testing write user profile...');
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'profile': {
          'test': true,
          'timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
      print('✅ User profile write successful');
      
      // Test 4: Ghi province data
      print('Testing write province data...');
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('provinces').doc('test_province').set({
        'id': 'test_province',
        'name': 'Test Province',
        'isUnlocked': true,
        'score': 100,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Province data write successful');
      
      print('🎉 All Firestore tests passed!');
      
    } catch (e) {
      print('❌ Firestore test failed: $e');
      print('Stack trace: ${StackTrace.current}');
    }
    
    print('=== FIRESTORE TEST COMPLETED ===');
  }

  // Test method để kiểm tra hệ thống
  static Future<void> testUserProgress() async {
    print('=== TESTING USER PROGRESS SYSTEM ===');
    
    // Test 1: Lấy tiến độ hiện tại
    final currentProgress = await getCurrentProgress();
    print('Current Progress - Total Score: ${currentProgress.totalScore}');
    print('Current Progress - Unlocked Provinces: ${currentProgress.provinces.where((p) => p.isUnlocked).length}');
    
    // Test 2: Cập nhật score
    await updateScore(100);
    print('Updated score by 100');
    
    // Test 3: Mở khóa một tỉnh
    await unlockProvince('hanoi');
    print('Unlocked Hanoi province');
    
    // Test 4: Cập nhật score cho tỉnh
    await updateProvinceScore('hanoi', 50);
    print('Updated Hanoi province score to 50');
    
    // Test 5: Đánh dấu tỉnh đã khám phá
    await exploreProvince('hanoi');
    print('Marked Hanoi as explored');
    
    // Test 6: Lấy tiến độ sau khi cập nhật
    final updatedProgress = await getCurrentProgress();
    print('Updated Progress - Total Score: ${updatedProgress.totalScore}');
    print('Updated Progress - Unlocked Provinces: ${updatedProgress.provinces.where((p) => p.isUnlocked).length}');
    
    // Test 7: Debug current progress
    await debugCurrentProgress();
    
    print('=== TEST COMPLETED ===');
  }

  // Test method để kiểm tra việc lưu và load
  static Future<void> testSaveAndLoad() async {
    print('=== TESTING SAVE AND LOAD ===');
    
    final userId = _currentUserId;
    print('Current User ID: $userId');
    
    // Test 1: Lưu dữ liệu test
    final testProgress = GameProgress(
      provinces: [
        Province(
          id: 'test_province',
          name: 'Test Province',
          nameVietnamese: 'Tỉnh Test',
          description: 'Test province for debugging',
          facts: ['Test fact 1', 'Test fact 2'],
          isUnlocked: true,
          isExplored: true,
          score: 100,
        ),
      ],
      totalScore: 500,
      dailyStreak: 5,
      lastPlayDate: DateTime.now(),
      unlockedProvincesCount: 1,
      completedDailyChallenges: ['test_challenge'],
    );
    
    await _saveToLocalStorage(testProgress, userId);
    print('Saved test progress to local storage');
    
    // Test 2: Load lại dữ liệu
    final loadedProgress = await _getLocalProgress(userId);
    print('Loaded Progress - Total Score: ${loadedProgress.totalScore}');
    print('Loaded Progress - Unlocked Provinces: ${loadedProgress.provinces.where((p) => p.isUnlocked).length}');
    print('Loaded Progress - Test Province Score: ${loadedProgress.provinces.firstWhere((p) => p.id == 'test_province', orElse: () => Province(id: '', name: '', nameVietnamese: '', description: '', facts: [])).score}');
    
    // Test 3: Debug current progress
    await debugCurrentProgress();
    
    print('=== SAVE AND LOAD TEST COMPLETED ===');
  }

  // Xóa dữ liệu local của user hiện tại
  static Future<void> clearLocalData() async {
    final userId = _currentUserId;
    final prefs = await SharedPreferences.getInstance();
    
    final userPrefix = userId ?? 'anonymous';
    final userUnlockedKey = '${userPrefix}_$_unlockedProvincesKey';
    final userTotalScoreKey = '${userPrefix}_$_totalScoreKey';
    final userDailyStreakKey = '${userPrefix}_$_dailyStreakKey';
    final userLastPlayDateKey = '${userPrefix}_$_lastPlayDateKey';
    final userExploredKey = '${userPrefix}_explored_provinces';
    
    await prefs.remove(userUnlockedKey);
    await prefs.remove(userTotalScoreKey);
    await prefs.remove(userDailyStreakKey);
    await prefs.remove(userLastPlayDateKey);
    await prefs.remove(userExploredKey);
    
    // Xóa tất cả province score keys
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('${userPrefix}_province_score_')) {
        await prefs.remove(key);
      }
    }
  }

  // Đồng bộ dữ liệu khi user đăng nhập
  static Future<void> syncOnLogin() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        // Lấy dữ liệu từ cloud
        final cloudProgress = await _userService.getCompleteGameProgress(userId);
        if (cloudProgress != null) {
          // Lưu vào local storage
          await _saveToLocalStorage(cloudProgress, userId);
        }
      } catch (e) {
        // Nếu không lấy được từ cloud, giữ nguyên local data
      }
    }
  }

  // Đồng bộ dữ liệu khi user đăng xuất
  static Future<void> syncOnLogout() async {
    final userId = _currentUserId;
    if (userId != null) {
      try {
        // Lưu dữ liệu local lên cloud trước khi đăng xuất
        final localProgress = await _getLocalProgress(userId);
        await _userService.saveGameProgress(userId, localProgress);
        await _userService.saveAllProvinces(userId, localProgress.provinces);
      } catch (e) {
        // Ignore sync error
      }
    }
  }

  // Xóa dữ liệu local khi đăng xuất (gọi sau khi sync)
  static Future<void> clearDataOnLogout() async {
    final userId = _currentUserId;
    if (userId != null) {
      await clearLocalData();
    }
  }
} 