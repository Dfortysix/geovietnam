import 'province.dart';

class GameProgress {
  final List<Province> provinces;
  final int totalScore;
  final int dailyStreak;
  final DateTime lastPlayDate;
  final int unlockedProvincesCount;
  final List<String> completedDailyChallenges;

  GameProgress({
    required this.provinces,
    this.totalScore = 0,
    this.dailyStreak = 0,
    required this.lastPlayDate,
    this.unlockedProvincesCount = 0,
    this.completedDailyChallenges = const [],
  });

  // Factory method để tạo GameProgress mới (reset state)
  factory GameProgress.initial() {
    return GameProgress(
      provinces: [], // Sẽ được load từ provinces_data.dart
      totalScore: 0,
      dailyStreak: 0,
      lastPlayDate: DateTime.now(),
      unlockedProvincesCount: 0,
      completedDailyChallenges: [],
    );
  }

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    return GameProgress(
      provinces: (json['provinces'] as List)
          .map((provinceJson) => Province.fromJson(provinceJson))
          .toList(),
      totalScore: json['totalScore'] ?? 0,
      dailyStreak: json['dailyStreak'] ?? 0,
      lastPlayDate: DateTime.parse(json['lastPlayDate']),
      unlockedProvincesCount: json['unlockedProvincesCount'] ?? 0,
      completedDailyChallenges: List<String>.from(json['completedDailyChallenges'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provinces': provinces.map((province) => province.toJson()).toList(),
      'totalScore': totalScore,
      'dailyStreak': dailyStreak,
      'lastPlayDate': lastPlayDate.toIso8601String(),
      'unlockedProvincesCount': unlockedProvincesCount,
      'completedDailyChallenges': completedDailyChallenges,
    };
  }

  GameProgress copyWith({
    List<Province>? provinces,
    int? totalScore,
    int? dailyStreak,
    DateTime? lastPlayDate,
    int? unlockedProvincesCount,
    List<String>? completedDailyChallenges,
  }) {
    return GameProgress(
      provinces: provinces ?? this.provinces,
      totalScore: totalScore ?? this.totalScore,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      unlockedProvincesCount: unlockedProvincesCount ?? this.unlockedProvincesCount,
      completedDailyChallenges: completedDailyChallenges ?? this.completedDailyChallenges,
    );
  }

  // Tính toán số tỉnh đã mở khóa
  int get unlockedCount => provinces.where((p) => p.isUnlocked).length;

  // Tính toán phần trăm hoàn thành
  double get completionPercentage => (unlockedCount / provinces.length) * 100;

  // Kiểm tra xem có thể mở khóa tỉnh mới không
  bool canUnlockNewProvince(int currentScore) {
    return unlockedCount < provinces.length && currentScore >= 70;
  }

  // Lấy tỉnh tiếp theo có thể mở khóa
  Province? getNextUnlockableProvince() {
    return provinces.firstWhere(
      (province) => !province.isUnlocked,
      orElse: () => provinces.first,
    );
  }
} 