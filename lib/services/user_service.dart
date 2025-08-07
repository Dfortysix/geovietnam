import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/game_progress.dart';
import '../models/province.dart';
import '../data/provinces_data.dart'; // Added import for ProvincesData

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tạo hoặc cập nhật user profile
  Future<void> createOrUpdateUserProfile(GoogleSignInAccount user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.id);
      
      await userDoc.set({
        'profile': {
          'displayName': user.displayName,
          'email': user.email,
          'photoUrl': user.photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
      
      print('User profile created/updated successfully');
    } catch (e) {
      print('Error creating/updating user profile: $e');
      rethrow;
    }
  }

  /// Lấy user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['profile'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Lưu game progress
  Future<void> saveGameProgress(String userId, GameProgress progress) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await userDoc.set({
        'gameProgress': {
          'totalScore': progress.totalScore,
          'dailyStreak': progress.dailyStreak,
          'lastPlayDate': FieldValue.serverTimestamp(),
          'unlockedProvincesCount': progress.unlockedProvincesCount,
          'completedDailyChallenges': progress.completedDailyChallenges,
        },
      }, SetOptions(merge: true));
      
      print('Game progress saved successfully');
    } catch (e) {
      print('Error saving game progress: $e');
      rethrow;
    }
  }

  /// Lấy game progress
  Future<GameProgress?> getGameProgress(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()?['gameProgress'] as Map<String, dynamic>?;
        if (data != null) {
          return GameProgress(
            provinces: [], // Sẽ load provinces riêng
            totalScore: data['totalScore'] ?? 0,
            dailyStreak: data['dailyStreak'] ?? 0,
            lastPlayDate: (data['lastPlayDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
            unlockedProvincesCount: data['unlockedProvincesCount'] ?? 0,
            completedDailyChallenges: List<String>.from(data['completedDailyChallenges'] ?? []),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting game progress: $e');
      return null;
    }
  }

  /// Lưu province data
  Future<void> saveProvinceData(String userId, Province province) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await userDoc.collection('provinces').doc(province.id).set({
        'id': province.id,
        'name': province.name,
        'isUnlocked': province.isUnlocked,
        'isExplored': province.isExplored,
        'score': province.score,
        'lastPlayed': FieldValue.serverTimestamp(),
      });
      
      print('Province data saved successfully');
    } catch (e) {
      print('Error saving province data: $e');
      rethrow;
    }
  }

  /// Lưu tất cả provinces
  Future<void> saveAllProvinces(String userId, List<Province> provinces) async {
    try {
      final batch = _firestore.batch();
      final userDoc = _firestore.collection('users').doc(userId);
      
      for (final province in provinces) {
        final provinceRef = userDoc.collection('provinces').doc(province.id);
        batch.set(provinceRef, {
          'id': province.id,
          'name': province.name,
          'isUnlocked': province.isUnlocked,
          'isExplored': province.isExplored,
          'score': province.score,
          'lastPlayed': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      print('All provinces saved successfully');
    } catch (e) {
      print('Error saving all provinces: $e');
      rethrow;
    }
  }

  /// Lấy tất cả provinces của user
  Future<List<Province>> getUserProvinces(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('provinces')
          .get();
      
      // Lấy danh sách tỉnh gốc để bổ sung thông tin thiếu
      final allProvinces = ProvincesData.getAllProvinces();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final base = allProvinces.firstWhere(
          (p) => p.id == data['id'],
          orElse: () => Province(
            id: data['id'] ?? '',
            name: data['name'] ?? '',
            nameVietnamese: data['nameVietnamese'] ?? '',
            description: data['description'] ?? '',
            facts: List<String>.from(data['facts'] ?? []),
          ),
        );
        return Province(
          id: data['id'] as String,
          name: data['name'] as String,
          nameVietnamese: data['nameVietnamese'] ?? base.nameVietnamese,
          isUnlocked: data['isUnlocked'] ?? false,
          isExplored: data['isExplored'] ?? false,
          score: data['score'] ?? 0,
          description: data['description'] ?? base.description,
          facts: data['facts'] != null ? List<String>.from(data['facts']) : base.facts,
        );
      }).toList();
    } catch (e) {
      print('Error getting user provinces: $e');
      return [];
    }
  }

  /// Lấy complete game progress với provinces
  Future<GameProgress?> getCompleteGameProgress(String userId) async {
    try {
      final progress = await getGameProgress(userId);
      final provinces = await getUserProvinces(userId);
      
      if (progress != null) {
        return progress.copyWith(provinces: provinces);
      }
      
      return null;
    } catch (e) {
      print('Error getting complete game progress: $e');
      return null;
    }
  }

  /// Cập nhật score cho province
  Future<void> updateProvinceScore(String userId, String provinceId, int score) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await userDoc.collection('provinces').doc(provinceId).update({
        'score': score,
        'lastPlayed': FieldValue.serverTimestamp(),
      });
      
      print('Province score updated successfully');
    } catch (e) {
      print('Error updating province score: $e');
      rethrow;
    }
  }

  /// Mở khóa province
  Future<void> unlockProvince(String userId, String provinceId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await userDoc.collection('provinces').doc(provinceId).update({
        'isUnlocked': true,
        'lastPlayed': FieldValue.serverTimestamp(),
      });
      
      print('Province unlocked successfully');
    } catch (e) {
      print('Error unlocking province: $e');
      rethrow;
    }
  }

  /// Đánh dấu province đã khám phá
  Future<void> exploreProvince(String userId, String provinceId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await userDoc.collection('provinces').doc(provinceId).update({
        'isExplored': true,
        'lastPlayed': FieldValue.serverTimestamp(),
      });
      
      print('Province explored successfully');
    } catch (e) {
      print('Error exploring province: $e');
      rethrow;
    }
  }

  /// Thêm daily challenge đã hoàn thành
  Future<void> addCompletedDailyChallenge(String userId, String challengeId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await userDoc.update({
        'gameProgress.completedDailyChallenges': FieldValue.arrayUnion([challengeId]),
      });
      
      print('Daily challenge completed successfully');
    } catch (e) {
      print('Error adding completed daily challenge: $e');
      rethrow;
    }
  }

  /// Cập nhật daily streak
  Future<void> updateDailyStreak(String userId, int streak) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await userDoc.update({
        'gameProgress.dailyStreak': streak,
        'gameProgress.lastPlayDate': FieldValue.serverTimestamp(),
      });
      
      print('Daily streak updated successfully');
    } catch (e) {
      print('Error updating daily streak: $e');
      rethrow;
    }
  }

  /// Cập nhật total score
  Future<void> updateTotalScore(String userId, int totalScore) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await userDoc.update({
        'gameProgress.totalScore': totalScore,
      });
      
      print('Total score updated successfully');
    } catch (e) {
      print('Error updating total score: $e');
      rethrow;
    }
  }
} 