import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class GooglePlayGamesService extends ChangeNotifier {
  static final GooglePlayGamesService _instance = GooglePlayGamesService._internal();
  factory GooglePlayGamesService() => _instance;
  GooglePlayGamesService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  bool _isSignedIn = false;
  bool _isInitialized = false;
  GoogleSignInAccount? _currentUser;

  // Getters
  bool get isSignedIn => _isSignedIn;
  bool get isInitialized => _isInitialized;
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Khởi tạo Google Play Games Services
  Future<bool> initialize() async {
    try {
      // Khởi tạo Firebase Analytics
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      
      // Kiểm tra trạng thái đăng nhập hiện tại
      _isSignedIn = await _googleSignIn.isSignedIn();
      if (_isSignedIn) {
        _currentUser = _googleSignIn.currentUser;
      }
      
      _isInitialized = true;
      notifyListeners();
      print('Google Play Games Services đã được khởi tạo thành công');
      return true;
    } catch (e) {
      print('Lỗi khởi tạo Google Play Games Services: $e');
      return false;
    }
  }

  /// Đăng nhập vào Google Play Games
  Future<bool> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        _isSignedIn = true;
        _currentUser = account;
        notifyListeners();
        print('Đăng nhập thành công: ${account.email}');
        print('Tên hiển thị: ${account.displayName}');
        print('ID: ${account.id}');
        print('Avatar URL: ${account.photoUrl}');
        
        // Ghi log analytics
        await FirebaseAnalytics.instance.logEvent(
          name: 'game_sign_in',
          parameters: {
            'method': 'google_play_games',
            'user_id': account.id,
            'email': account.email,
            'display_name': account.displayName ?? '',
          },
        );
        
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return false;
    }
  }

  /// Đăng xuất khỏi Google Play Games
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _isSignedIn = false;
      _currentUser = null;
      notifyListeners();
      print('Đăng xuất thành công');
    } catch (e) {
      print('Lỗi đăng xuất: $e');
    }
  }

  /// Ghi log sự kiện game
  Future<void> logGameEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      print('Lỗi ghi log sự kiện: $e');
    }
  }

  /// Ghi log điểm số (để tích hợp với leaderboard sau này)
  Future<void> logScore({
    required int score,
    String? gameMode,
  }) async {
    try {
              await FirebaseAnalytics.instance.logEvent(
          name: 'game_score',
          parameters: {
            'score': score,
            'game_mode': gameMode ?? 'default',
            'user_id': _currentUser?.id ?? '',
          },
        );
      print('Điểm số đã được ghi log: $score');
    } catch (e) {
      print('Lỗi ghi log điểm số: $e');
    }
  }

  /// Ghi log achievement (để tích hợp với achievements sau này)
  Future<void> logAchievement({
    required String achievementId,
    String? achievementName,
  }) async {
    try {
              await FirebaseAnalytics.instance.logEvent(
          name: 'achievement_unlocked',
          parameters: {
            'achievement_id': achievementId,
            'achievement_name': achievementName ?? achievementId,
            'user_id': _currentUser?.id ?? '',
          },
        );
      print('Achievement đã được ghi log: $achievementId');
    } catch (e) {
      print('Lỗi ghi log achievement: $e');
    }
  }

  /// Ghi log sự kiện khám phá tỉnh thành
  Future<void> logProvinceExplored({
    required String provinceName,
    required String provinceId,
  }) async {
    try {
              await FirebaseAnalytics.instance.logEvent(
          name: 'province_explored',
          parameters: {
            'province_name': provinceName,
            'province_id': provinceId,
            'user_id': _currentUser?.id ?? '',
          },
        );
    } catch (e) {
      print('Lỗi ghi log khám phá tỉnh: $e');
    }
  }

  /// Ghi log sự kiện hoàn thành thử thách
  Future<void> logChallengeCompleted({
    required String challengeType,
    required int score,
    String? difficulty,
  }) async {
    try {
              await FirebaseAnalytics.instance.logEvent(
          name: 'challenge_completed',
          parameters: {
            'challenge_type': challengeType,
            'score': score,
            'difficulty': difficulty ?? 'normal',
            'user_id': _currentUser?.id ?? '',
          },
        );
    } catch (e) {
      print('Lỗi ghi log hoàn thành thử thách: $e');
    }
  }
} 