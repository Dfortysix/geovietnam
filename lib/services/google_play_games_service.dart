import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';
import 'game_progress_service.dart';
import 'auth_service.dart';

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

  final UserService _userService = UserService();

  bool _isSignedIn = false;
  bool _isInitialized = false;
  GoogleSignInAccount? _currentUser;

  // Getters
  bool get isSignedIn => _isSignedIn;
  bool get isInitialized => _isInitialized;
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Refresh trạng thái đăng nhập hiện tại
  Future<void> refreshSignInStatus() async {
    try {
      final wasSignedIn = _isSignedIn;
      _isSignedIn = await _googleSignIn.isSignedIn();
      
      if (_isSignedIn) {
        // Đảm bảo load thông tin user đầy đủ
        _currentUser = await _googleSignIn.signInSilently();
        if (_currentUser == null) {
          // Nếu không load được, thử lấy current user
          _currentUser = _googleSignIn.currentUser;
        }
      } else {
        _currentUser = null;
      }
      
      // Chỉ notify nếu có thay đổi
      if (wasSignedIn != _isSignedIn || _currentUser != null) {
        notifyListeners();
        print('Refresh sign in status: $_isSignedIn - ${_currentUser?.displayName}');
      }
    } catch (e) {
      print('Lỗi refresh sign in status: $e');
    }
  }

  /// Khởi tạo Google Play Games Services
  Future<bool> initialize() async {
    try {
      // Khởi tạo Firebase Analytics
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      
      // Kiểm tra trạng thái đăng nhập hiện tại
      _isSignedIn = await _googleSignIn.isSignedIn();
      if (_isSignedIn) {
        // Đảm bảo load thông tin user đầy đủ
        _currentUser = await _googleSignIn.signInSilently();
        if (_currentUser == null) {
          // Nếu không load được, thử lấy current user
          _currentUser = _googleSignIn.currentUser;
        }
      }
      
      _isInitialized = true;
      notifyListeners();
      print('Google Play Games Services đã được khởi tạo thành công');
      print('Trạng thái đăng nhập: $_isSignedIn');
      print('User hiện tại: ${_currentUser?.displayName} (${_currentUser?.email})');
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
        // Liên kết với Firebase Auth
        final GoogleSignInAuthentication googleAuth = await account.authentication;
        
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        _isSignedIn = true;
        _currentUser = account;
        notifyListeners();
        
        // Đợi để Firebase Auth hoàn tất
        await Future.delayed(Duration(milliseconds: 1000));
        
        // Tạo hoặc cập nhật user profile trên Firestore
        try {
          await _userService.createOrUpdateUserProfile(account);
        } catch (profileError) {
          // Không throw error để không làm gián đoạn quá trình đăng nhập
        }
        
        // Đồng bộ dữ liệu game progress
        try {
          await GameProgressService.syncOnLogin();
        } catch (syncError) {
          // Ignore sync error
        }
        
        // Ghi log analytics
        try {
          await FirebaseAnalytics.instance.logEvent(
            name: 'game_sign_in',
            parameters: {
              'method': 'google_play_games',
              'user_id': account.id,
              'email': account.email,
              'display_name': account.displayName ?? '',
            },
          );
        } catch (analyticsError) {
          // Ignore analytics error
        }
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Đăng xuất khỏi Google Play Games
  Future<void> signOut() async {
    try {
      // Đồng bộ dữ liệu trước khi đăng xuất
      try {
        await GameProgressService.syncOnLogout();
      } catch (syncError) {
        // Ignore sync error
      }
      
                              await _googleSignIn.signOut();
                        _isSignedIn = false;
                        _currentUser = null;
                        notifyListeners();
                        
                        // Refresh UI của AuthService
                        AuthService().refreshUI();
      
      // Xóa dữ liệu local sau khi đăng xuất
      try {
        await GameProgressService.clearDataOnLogout();
      } catch (clearError) {
        // Ignore clear error
      }
    } catch (e) {
      // Ignore sign out error
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
      // Ignore analytics error
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
    } catch (e) {
      // Ignore analytics error
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
    } catch (e) {
      // Ignore analytics error
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
      // Ignore analytics error
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
      // Ignore analytics error
    }
  }
} 