import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/province.dart';
import '../data/provinces_data.dart';
import 'game_progress_service.dart';

class DailyChallengeService {
  static const String _dailyChallengeDateKey = 'daily_challenge_date';
  static const String _dailyChallengeAttemptsKey = 'daily_challenge_attempts';
  static const String _dailyChallengeProvinceKey = 'daily_challenge_province';
  static const int _maxAttemptsPerDay = 3;

  // Lấy thông tin daily challenge hiện tại
  static Future<Map<String, dynamic>> getCurrentDailyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final lastChallengeDate = prefs.getString(_dailyChallengeDateKey);
    final attempts = prefs.getInt(_dailyChallengeAttemptsKey) ?? 0;
    final selectedProvinceId = prefs.getString(_dailyChallengeProvinceKey);
    final isProvinceUnlockedToday = prefs.getBool('province_unlocked_today') ?? false;
    
         // Nếu là ngày mới, reset daily challenge
     if (lastChallengeDate != todayString) {
       await _resetDailyChallenge(todayString);
       
       // Kiểm tra xem có tỉnh được chọn không sau khi reset
       final currentProvinceId = prefs.getString(_dailyChallengeProvinceKey);
       Province selectedProvince;
       
       if (currentProvinceId != null) {
         // Nếu có tỉnh được chọn (tỉnh trước chưa unlock), sử dụng tỉnh đó
         if (currentProvinceId == 'Ha Noi') {
           selectedProvince = Province(
             id: 'Ha Noi',
             name: 'Ha Noi',
             nameVietnamese: 'Hà Nội',
             description: 'Thủ đô của Việt Nam',
             facts: [],
             isUnlocked: true,
           );
         } else if (currentProvinceId == 'Hai Phong') {
           selectedProvince = Province(
             id: 'Hai Phong',
             name: 'Hai Phong',
             nameVietnamese: 'Hải Phòng',
             description: 'Thành phố cảng lớn nhất miền Bắc',
             facts: [],
             isUnlocked: true,
           );
         } else {
           selectedProvince = await _selectRandomProvince();
         }
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
    
         // Tìm tỉnh được chọn từ danh sách có sẵn
     Province? selectedProvince;
     if (selectedProvinceId != null) {
       if (selectedProvinceId == 'Ha Noi') {
         selectedProvince = Province(
           id: 'Ha Noi',
           name: 'Ha Noi',
           nameVietnamese: 'Hà Nội',
           description: 'Thủ đô của Việt Nam',
           facts: [],
           isUnlocked: true,
         );
       } else if (selectedProvinceId == 'Hai Phong') {
         selectedProvince = Province(
           id: 'Hai Phong',
           name: 'Hai Phong',
           nameVietnamese: 'Hải Phòng',
           description: 'Thành phố cảng lớn nhất miền Bắc',
           facts: [],
           isUnlocked: true,
         );
       }
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
    final prefs = await SharedPreferences.getInstance();
    final previousProvinceId = prefs.getString(_dailyChallengeProvinceKey);
    
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
      }
    }
    
    await prefs.setString(_dailyChallengeDateKey, todayString);
    await prefs.setInt(_dailyChallengeAttemptsKey, 0);
    await prefs.setBool('province_unlocked_today', false); // Reset trạng thái unlock
    
    // Chỉ chọn tỉnh mới nếu tỉnh trước đã được unlock
    if (shouldChangeProvince) {
      await prefs.remove(_dailyChallengeProvinceKey);
    }
  }

  // Chọn tỉnh random cho daily challenge (chỉ từ 2 tỉnh có sẵn data)
  static Future<Province> _selectRandomProvince() async {
    // Chỉ sử dụng 2 tỉnh có sẵn file JSON
    final availableProvinces = [
      Province(
        id: 'Ha Noi',
        name: 'Ha Noi',
        nameVietnamese: 'Hà Nội',
        description: 'Thủ đô của Việt Nam',
        facts: [],
        isUnlocked: true,
      ),
      Province(
        id: 'Hai Phong',
        name: 'Hai Phong',
        nameVietnamese: 'Hải Phòng',
        description: 'Thành phố cảng lớn nhất miền Bắc',
        facts: [],
        isUnlocked: true,
      ),
    ];
    
    final random = Random();
    final selectedProvince = availableProvinces[random.nextInt(availableProvinces.length)];
    
    // Lưu tỉnh được chọn
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyChallengeProvinceKey, selectedProvince.id);
    
    return selectedProvince;
  }

  // Tăng số lần thử
  static Future<void> incrementAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_dailyChallengeAttemptsKey) ?? 0;
    await prefs.setInt(_dailyChallengeAttemptsKey, attempts + 1);
  }

  // Đánh dấu tỉnh đã được unlock hôm nay
  static Future<void> markProvinceUnlockedToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('province_unlocked_today', true);
  }

  // Load câu hỏi cho tỉnh được chọn
  static Future<List<Map<String, dynamic>>> loadQuestionsForProvince(String provinceId) async {
    try {
      // Tìm file JSON tương ứng với tỉnh
      String fileName;
      if (provinceId == 'Ha Noi') {
        fileName = 'hanoi_questions.json';
      } else if (provinceId == 'Hai Phong') {
        fileName = 'haiphong_questions.json';
      } else {
        fileName = '${provinceId.toLowerCase()}_questions.json';
      }
      
      final jsonString = await rootBundle.loadString('assets/data/$fileName');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Chuyển đổi thành List<Map<String, dynamic>>
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
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
} 