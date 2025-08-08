import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';

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
      print('=== GOOGLE SIGN-IN START ===');
      
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        print('Google Sign-In successful: ${account.email}');
        print('Google Account ID: ${account.id}');
        print('Google Display Name: ${account.displayName}');
        
        // Liên kết với Firebase Auth
        print('Getting Google authentication...');
        final GoogleSignInAuthentication googleAuth = await account.authentication;
        print('Google Auth Access Token: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}');
        print('Google Auth ID Token: ${googleAuth.idToken != null ? 'Present' : 'Missing'}');
        
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        print('Signing in to Firebase with Google credential...');
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        
        // Debug Firebase Auth
        print('=== FIREBASE AUTH RESULT ===');
        print('Firebase Auth User ID: ${userCredential.user?.uid}');
        print('Firebase Auth Email: ${userCredential.user?.email}');
        print('Firebase Auth Display Name: ${userCredential.user?.displayName}');
        print('Firebase Auth isAnonymous: ${userCredential.user?.isAnonymous}');
        print('Firebase Auth isEmailVerified: ${userCredential.user?.emailVerified}');
        print('Firebase Auth Provider Data: ${userCredential.user?.providerData.map((p) => p.providerId).toList()}');
        print('==========================');

        _isSignedIn = true;
        _currentUser = account;
        notifyListeners();
        
        // Đợi để Firebase Auth hoàn tất
        print('Waiting for Firebase Auth to complete...');
        await Future.delayed(Duration(milliseconds: 1000));
        
        // Debug Firebase Auth trước khi ghi Firestore
        final User? currentFirebaseUser = FirebaseAuth.instance.currentUser;
        print('=== CURRENT FIREBASE USER ===');
        print('Current Firebase User: ${currentFirebaseUser?.uid}');
        print('Firebase User Email: ${currentFirebaseUser?.email}');
        print('Firebase User Display Name: ${currentFirebaseUser?.displayName}');
        print('Firebase User isAnonymous: ${currentFirebaseUser?.isAnonymous}');
        print('Firebase User isEmailVerified: ${currentFirebaseUser?.emailVerified}');
        print('==========================');
        
        // Tạo hoặc cập nhật user profile trên Firestore
        print('=== CREATING USER PROFILE ===');
        print('Firebase Auth User ID: ${userCredential.user?.uid}');
        print('Google Sign-In ID: ${account.id}');
        print('==========================');
        
        try {
          await _userService.createOrUpdateUserProfile(account);
          print('User profile created/updated successfully');
        } catch (profileError) {
          print('Error creating user profile: $profileError');
          // Không throw error để không làm gián đoạn quá trình đăng nhập
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
          print('Analytics event logged successfully');
        } catch (analyticsError) {
          print('Error logging analytics: $analyticsError');
        }
        
        print('=== GOOGLE SIGN-IN COMPLETED ===');
        return true;
      } else {
        print('Google Sign-In cancelled by user');
        return false;
      }
    } catch (e) {
      print('=== GOOGLE SIGN-IN ERROR ===');
      print('Error during sign-in: $e');
      print('Stack trace: ${StackTrace.current}');
      print('==========================');
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