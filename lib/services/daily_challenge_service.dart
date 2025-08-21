import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/province.dart';
import '../data/provinces_data.dart';
import 'game_progress_service.dart';
import 'auth_service.dart';

class DailyChallengeService {
  static const String _dailyChallengeDateKey = 'daily_challenge_date';
  static const String _dailyChallengeAttemptsKey = 'daily_challenge_attempts';
  static const String _dailyChallengeProvinceKey = 'daily_challenge_province';
  static const String _dailyChallengeCurrentQuestionKey = 'daily_challenge_current_question';
  static const String _dailyChallengeScoreKey = 'daily_challenge_score';
  static const String _dailyChallengeQuestionsKey = 'daily_challenge_questions';
  static const String _dailyChallengeSelectedAnswerKey = 'daily_challenge_selected_answer';
  static const String _dailyChallengeShowResultKey = 'daily_challenge_show_result';
  static const String _dailyChallengeIsCorrectKey = 'daily_challenge_is_correct';
  static const String _dailyChallengeTimeRemainingKey = 'daily_challenge_time_remaining';
  static const int _maxAttemptsPerDay = 3;

  // Lấy key với user ID để phân biệt theo từng tài khoản
  static String _getUserKey(String baseKey) {
    final authService = AuthService();
    final user = authService.currentUser;
    final googleUser = authService.currentGoogleUser;
    
    // Sử dụng Firebase UID nếu có, hoặc Google ID, hoặc fallback
    String userId;
    if (user?.uid != null) {
      userId = user!.uid;
    } else if (googleUser?.id != null) {
      userId = googleUser!.id;
    } else {
      userId = 'anonymous_user';
    }
    
    return '${userId}_$baseKey';
  }

  // Lấy thông tin daily challenge hiện tại
  static Future<Map<String, dynamic>> getCurrentDailyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final lastChallengeDate = prefs.getString(_getUserKey(_dailyChallengeDateKey));
    final attempts = prefs.getInt(_getUserKey(_dailyChallengeAttemptsKey)) ?? 0;
    final selectedProvinceId = prefs.getString(_getUserKey(_dailyChallengeProvinceKey));
    final isProvinceUnlockedToday = prefs.getBool(_getUserKey('province_unlocked_today')) ?? false;
    
         // Nếu là ngày mới, reset daily challenge
     if (lastChallengeDate != todayString) {
       await _resetDailyChallenge(todayString);
       
               // Kiểm tra xem có tỉnh được chọn không sau khi reset
        final currentProvinceId = prefs.getString(_getUserKey(_dailyChallengeProvinceKey));
       Province selectedProvince;
       
                       if (currentProvinceId != null) {
           // Nếu có tỉnh được chọn, tìm tỉnh đó trong game progress
           final progress = await GameProgressService.getCurrentProgress();
           final existingProvince = progress.provinces.firstWhere(
             (p) => p.id == currentProvinceId,
             orElse: () => Province(
               id: currentProvinceId,
               name: currentProvinceId,
               nameVietnamese: currentProvinceId,
               description: 'Tỉnh',
               facts: [],
               isUnlocked: false,
             ),
           );
           selectedProvince = existingProvince;
        } else {
          // Nếu không có tỉnh được chọn, chọn tỉnh mới
          selectedProvince = await _selectRandomProvince();
        }
       
       return {
         'date': todayString,
         'attempts': 0,
         'maxAttempts': _maxAttemptsPerDay,
         'canPlay': true,
         'selectedProvince': selectedProvince,
       };
     }
    
         // Kiểm tra xem còn có thể chơi không
     final canPlay = attempts < _maxAttemptsPerDay && !isProvinceUnlockedToday;
    
                      // Tìm tỉnh được chọn từ game progress
       Province? selectedProvince;
       if (selectedProvinceId != null) {
         final progress = await GameProgressService.getCurrentProgress();
         final existingProvince = progress.provinces.firstWhere(
           (p) => p.id == selectedProvinceId,
           orElse: () => Province(
             id: selectedProvinceId,
             name: selectedProvinceId,
             nameVietnamese: selectedProvinceId,
             description: 'Tỉnh',
             facts: [],
             isUnlocked: false,
           ),
         );
         selectedProvince = existingProvince;
       }
     
     return {
       'date': lastChallengeDate ?? todayString,
       'attempts': attempts,
       'maxAttempts': _maxAttemptsPerDay,
       'canPlay': canPlay,
       'selectedProvince': selectedProvince,
       'isProvinceUnlockedToday': isProvinceUnlockedToday,
     };
  }

  // Reset daily challenge cho ngày mới
  static Future<void> _resetDailyChallenge(String todayString) async {
    print('🔄 Bắt đầu reset daily challenge cho ngày: $todayString');
    final prefs = await SharedPreferences.getInstance();
    final previousProvinceId = prefs.getString(_getUserKey(_dailyChallengeProvinceKey));
    
    // Kiểm tra xem tỉnh trước đó đã được unlock chưa
    bool shouldChangeProvince = true;
    if (previousProvinceId != null) {
      final progress = await GameProgressService.getCurrentProgress();
      final previousProvince = progress.provinces.firstWhere(
        (p) => p.id == previousProvinceId,
        orElse: () => progress.provinces.first,
      );
      
      // Nếu tỉnh trước đó chưa được unlock, giữ nguyên
      if (!previousProvince.isUnlocked) {
        shouldChangeProvince = false;
        print('📍 Giữ nguyên tỉnh $previousProvinceId vì chưa unlock');
      } else {
        print('📍 Tỉnh $previousProvinceId đã unlock, sẽ chọn tỉnh mới');
      }
    }
    
    await prefs.setString(_getUserKey(_dailyChallengeDateKey), todayString);
    await prefs.setInt(_getUserKey(_dailyChallengeAttemptsKey), 0);
    await prefs.setBool(_getUserKey('province_unlocked_today'), false); // Reset trạng thái unlock
    
    // Xóa trạng thái chơi cũ khi reset daily challenge
    await clearSavedGameState();
    print('🗑️ Đã xóa trạng thái chơi cũ');
    
    // Chỉ chọn tỉnh mới nếu tỉnh trước đã được unlock
    if (shouldChangeProvince) {
      await prefs.remove(_getUserKey(_dailyChallengeProvinceKey));
      print('🔄 Đã xóa tỉnh cũ, sẽ chọn tỉnh mới');
    } else {
      print('🔄 Giữ nguyên tỉnh cũ: $previousProvinceId');
    }
  }

  // Chọn tỉnh random cho daily challenge (chỉ từ các tỉnh chưa mở khóa)
  static Future<Province> _selectRandomProvince() async {
    // Lấy danh sách tất cả tỉnh từ game progress
    final progress = await GameProgressService.getCurrentProgress();
    
    // Lọc ra các tỉnh chưa được unlock và có sẵn file questions
    final unlockedProvinces = progress.provinces.where((province) => 
      !province.isUnlocked && 
      _hasQuestionsFile(province.id)
    ).toList();
    
         // Nếu không có tỉnh nào chưa unlock, lấy tất cả tỉnh có questions từ game progress
     if (unlockedProvinces.isEmpty) {
       // Lọc ra tất cả tỉnh có questions từ game progress
       final allProvincesWithQuestions = progress.provinces.where((province) => 
         _hasQuestionsFile(province.id)
       ).toList();
       
       if (allProvincesWithQuestions.isNotEmpty) {
         final random = Random();
         final selectedProvince = allProvincesWithQuestions[random.nextInt(allProvincesWithQuestions.length)];
         
         // Lưu tỉnh được chọn
         final prefs = await SharedPreferences.getInstance();
         await prefs.setString(_getUserKey(_dailyChallengeProvinceKey), selectedProvince.id);
         
         return selectedProvince;
       }
       
       // Fallback: nếu không có tỉnh nào trong game progress, tạo tỉnh mặc định
       final defaultProvince = Province(
         id: 'Ha Noi',
         name: 'Ha Noi',
         nameVietnamese: 'Hà Nội',
         description: 'Thủ đô của Việt Nam',
         facts: [],
         isUnlocked: false,
       );
       
       final prefs = await SharedPreferences.getInstance();
       await prefs.setString(_getUserKey(_dailyChallengeProvinceKey), defaultProvince.id);
       
       return defaultProvince;
     }
    
    // Random từ danh sách tỉnh chưa unlock
    final random = Random();
    final selectedProvince = unlockedProvinces[random.nextInt(unlockedProvinces.length)];
    
    // Lưu tỉnh được chọn
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getUserKey(_dailyChallengeProvinceKey), selectedProvince.id);
    
    return selectedProvince;
  }
  
  // Kiểm tra xem tỉnh có file questions không
  static bool _hasQuestionsFile(String provinceId) {
    final availableProvinces = [
      'An Giang', 'Bac Ninh', 'Ca Mau', 'Can Tho', 'Cao Bang', 'Da Nang',
      'Dak Lak', 'Dien Bien', 'Dong Nai', 'Dong Thap', 'Gia Lai', 'Ha Noi',
      'Ha Tinh', 'Hai Phong', 'Ho Chi Minh', 'Hue', 'Hung Yen', 'Khanh Hoa',
      'Lai Chau', 'Lam Dong', 'Lang Son', 'Lao Cai', 'Nghe An', 'Ninh Binh',
      'Phu Tho', 'Quang Ngai', 'Quang Ninh', 'Quang Tri', 'Son La', 'Tay Ninh',
      'Thai Nguyen', 'Thanh Hoa', 'Tuyen Quang', 'Vinh Long'
    ];
    return availableProvinces.contains(provinceId);
  }

  // Tăng số lần thử
  static Future<void> incrementAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_getUserKey(_dailyChallengeAttemptsKey)) ?? 0;
    await prefs.setInt(_getUserKey(_dailyChallengeAttemptsKey), attempts + 1);
  }

  // Đánh dấu tỉnh đã được unlock hôm nay
  static Future<void> markProvinceUnlockedToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getUserKey('province_unlocked_today'), true);
  }

  // Load câu hỏi cho tỉnh được chọn
  static Future<List<Map<String, dynamic>>> loadQuestionsForProvince(String provinceId) async {
    try {
      // Tên file theo quy tắc snake_case: ví dụ 'Ha Noi' -> 'ha_noi.json'
      final fileName = '${provinceId.toLowerCase().replaceAll(' ', '_')}.json';
      
      print('Loading questions for province: $provinceId, file: $fileName');
      final jsonString = await rootBundle.loadString('assets/data/questions/$fileName');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Chuyển đổi thành List<Map<String, dynamic>>
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error loading questions for province $provinceId: $e');
      // Nếu không tìm thấy file, trả về câu hỏi mặc định
      return _getDefaultQuestions();
    }
  }

  // Câu hỏi mặc định nếu không tìm thấy file
  static List<Map<String, dynamic>> _getDefaultQuestions() {
    return [
      {
        "id": "default_001",
        "type": "text",
        "question": "Việt Nam có bao nhiêu tỉnh thành?",
        "options": ["61", "62", "63", "64"],
        "answer": 2
      },
      {
        "id": "default_002",
        "type": "text",
        "question": "Thủ đô của Việt Nam là?",
        "options": ["Hà Nội", "TP. Hồ Chí Minh", "Đà Nẵng", "Huế"],
        "answer": 0
      },
      {
        "id": "default_003",
        "type": "text",
        "question": "Việt Nam có đường bờ biển dài khoảng bao nhiêu km?",
        "options": ["2,000 km", "3,260 km", "4,000 km", "5,000 km"],
        "answer": 1
      },
      {
        "id": "default_004",
        "type": "text",
        "question": "Sông nào dài nhất Việt Nam?",
        "options": ["Sông Hồng", "Sông Mekong", "Sông Đồng Nai", "Sông Cửu Long"],
        "answer": 1
      },
      {
        "id": "default_005",
        "type": "text",
        "question": "Núi nào cao nhất Việt Nam?",
        "options": ["Fansipan", "Bà Đen", "Lang Biang", "Bạch Mã"],
        "answer": 0
      },
      {
        "id": "default_006",
        "type": "text",
        "question": "Việt Nam có chung biên giới với bao nhiêu quốc gia?",
        "options": ["2", "3", "4", "5"],
        "answer": 1
      },
      {
        "id": "default_007",
        "type": "text",
        "question": "Đồng bằng sông Cửu Long có bao nhiêu tỉnh thành?",
        "options": ["10", "11", "12", "13"],
        "answer": 2
      }
    ];
  }

  // Kiểm tra xem có thể chơi daily challenge không
  static Future<bool> canPlayDailyChallenge() async {
    final challenge = await getCurrentDailyChallenge();
    return challenge['canPlay'] as bool;
  }

  // Lấy số lần thử còn lại
  static Future<int> getRemainingAttempts() async {
    final challenge = await getCurrentDailyChallenge();
    return _maxAttemptsPerDay - (challenge['attempts'] as int);
  }

  // Lưu trạng thái chơi hiện tại
  static Future<void> saveGameState({
    required int currentQuestion,
    required int score,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_getUserKey(_dailyChallengeCurrentQuestionKey), currentQuestion);
      await prefs.setInt(_getUserKey(_dailyChallengeScoreKey), score);
      await prefs.setString(_getUserKey(_dailyChallengeQuestionsKey), json.encode(questions));
      print('✅ Đã lưu trạng thái: câu $currentQuestion, điểm $score');
    } catch (e) {
      print('❌ Lỗi khi lưu trạng thái: $e');
    }
  }

  // Lấy trạng thái chơi đã lưu
  static Future<Map<String, dynamic>> getSavedGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentQuestion = prefs.getInt(_getUserKey(_dailyChallengeCurrentQuestionKey)) ?? 0;
      final score = prefs.getInt(_getUserKey(_dailyChallengeScoreKey)) ?? 0;
      final questionsString = prefs.getString(_getUserKey(_dailyChallengeQuestionsKey));

      List<Map<String, dynamic>> questions = [];
      if (questionsString != null) {
        try {
          final List<dynamic> questionsList = json.decode(questionsString);
          questions = questionsList.map((item) => Map<String, dynamic>.from(item)).toList();
        } catch (e) {
          print('Error parsing saved questions: $e');
        }
      }

      print('📖 Đã khôi phục trạng thái: câu $currentQuestion, điểm $score');
      return {
        'currentQuestion': currentQuestion,
        'score': score,
        'questions': questions,
      };
    } catch (e) {
      print('❌ Lỗi khi khôi phục trạng thái: $e');
      return {
        'currentQuestion': 0,
        'score': 0,
        'questions': [],
      };
    }
  }

  // Xóa trạng thái chơi đã lưu
  static Future<void> clearSavedGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getUserKey(_dailyChallengeCurrentQuestionKey));
    await prefs.remove(_getUserKey(_dailyChallengeScoreKey));
    await prefs.remove(_getUserKey(_dailyChallengeQuestionsKey));
  }

  // Kiểm tra xem có trạng thái chơi đã lưu không
  static Future<bool> hasSavedGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasState = prefs.containsKey(_getUserKey(_dailyChallengeCurrentQuestionKey));
      final currentQuestion = prefs.getInt(_getUserKey(_dailyChallengeCurrentQuestionKey));
      final score = prefs.getInt(_getUserKey(_dailyChallengeScoreKey));
      print('🔍 Kiểm tra trạng thái đã lưu: $hasState (câu: $currentQuestion, điểm: $score)');
      return hasState;
    } catch (e) {
      print('❌ Lỗi khi kiểm tra trạng thái: $e');
      return false;
    }
  }

  // Debug: In ra tất cả SharedPreferences keys
  static Future<void> debugSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      print('🔍 Tất cả SharedPreferences keys:');
      for (final key in keys) {
        if (key.contains('daily_challenge')) {
          final value = prefs.get(key);
          print('  $key: $value');
        }
      }
      print('👤 User-specific keys:');
      final authService = AuthService();
      final user = authService.currentUser;
      final googleUser = authService.currentGoogleUser;
      
      String userId;
      if (user?.uid != null) {
        userId = user!.uid;
      } else if (googleUser?.id != null) {
        userId = googleUser!.id;
      } else {
        userId = 'anonymous_user';
      }
      
      for (final key in keys) {
        if (key.startsWith('${userId}_daily_challenge')) {
          final value = prefs.get(key);
          print('  $key: $value');
        }
      }
    } catch (e) {
      print('❌ Lỗi khi debug SharedPreferences: $e');
    }
  }

  // Xóa tất cả dữ liệu daily challenge của user hiện tại (khi đăng xuất)
  static Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final authService = AuthService();
      final user = authService.currentUser;
      final googleUser = authService.currentGoogleUser;
      
      String userId;
      if (user?.uid != null) {
        userId = user!.uid;
      } else if (googleUser?.id != null) {
        userId = googleUser!.id;
      } else {
        userId = 'anonymous_user';
      }
      
      int removedCount = 0;
      for (final key in keys) {
        if (key.startsWith('${userId}_daily_challenge')) {
          await prefs.remove(key);
          removedCount++;
        }
      }
      
      print('🗑️ Đã xóa $removedCount keys daily challenge của user $userId');
    } catch (e) {
      print('❌ Lỗi khi xóa dữ liệu user: $e');
    }
  }
} 