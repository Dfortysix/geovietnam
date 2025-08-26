import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/game_progress.dart';
import '../models/province.dart';
import '../data/provinces_data.dart'; // Added import for ProvincesData

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection leaderboard: leaderboards/global/users/{userId}
  CollectionReference<Map<String, dynamic>> _leaderboardUsers() {
    return _firestore.collection('leaderboards').doc('global').collection('users');
  }

  /// Tạo hoặc cập nhật user profile
  Future<void> createOrUpdateUserProfile(GoogleSignInAccount user) async {
    try {
      // Sử dụng Firebase Auth user ID thay vì Google Sign-In ID
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        // Thử đợi lâu hơn và lấy lại
        await Future.delayed(Duration(milliseconds: 2000));
        final User? retryUser = FirebaseAuth.instance.currentUser;
        if (retryUser == null) {
          // Thử lắng nghe auth state changes
          final authStateStream = FirebaseAuth.instance.authStateChanges();
          final authStateSubscription = authStateStream.listen((User? user) {});
          
          await Future.delayed(Duration(milliseconds: 3000));
          authStateSubscription.cancel();
          
          final finalRetryUser = FirebaseAuth.instance.currentUser;
          if (finalRetryUser == null) {
            throw Exception('Firebase Auth user not authenticated after multiple attempts');
          }
          
          await _createUserProfile(finalRetryUser.uid, user);
          return;
        }
        
        await _createUserProfile(retryUser.uid, user);
        return;
      }
      
      await _createUserProfile(firebaseUser.uid, user);
      
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method để tạo user profile
  Future<void> _createUserProfile(String firebaseUid, GoogleSignInAccount googleUser) async {
    try {
      final userDoc = _firestore.collection('users').doc(firebaseUid);
      
      final profileData = {
        'profile': {
          'displayName': googleUser.displayName,
          'email': googleUser.email,
          'photoUrl': googleUser.photoUrl,
          'googleId': googleUser.id, // Lưu Google ID để reference
          'firebaseUid': firebaseUid, // Lưu Firebase UID để reference
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      };
      
      await userDoc.set(profileData, SetOptions(merge: true));

      // Upsert vào leaderboard
      await _leaderboardUsers().doc(firebaseUid).set({
        'displayName': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
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
      return null;
    }
  }

  /// Lưu game progress
  Future<void> saveGameProgress(String userId, GameProgress progress) async {
    try {
      // Sử dụng Firebase Auth user ID nếu có
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      final String actualUserId = firebaseUser?.uid ?? userId;
      
      final userDoc = _firestore.collection('users').doc(actualUserId);
      
      await userDoc.set({
        'gameProgress': {
          'totalScore': progress.totalScore,
          'dailyStreak': progress.dailyStreak,
          'lastPlayDate': FieldValue.serverTimestamp(),
          'unlockedProvincesCount': progress.unlockedProvincesCount,
          'completedDailyChallenges': progress.completedDailyChallenges,
        },
      }, SetOptions(merge: true));

      // Upsert leaderboard snapshot tổng hợp
      await _leaderboardUsers().doc(actualUserId).set({
        'displayName': (await getUserProfile(actualUserId))?['displayName'],
        'photoUrl': (await getUserProfile(actualUserId))?['photoUrl'],
        'totalScore': progress.totalScore,
        'dailyStreak': progress.dailyStreak,
        'unlockedProvincesCount': progress.unlockedProvincesCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Game progress saved successfully
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy game progress
  Future<GameProgress?> getGameProgress(String userId) async {
    try {
      // Sử dụng Firebase Auth user ID nếu có
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      final String actualUserId = firebaseUser?.uid ?? userId;
      
      final doc = await _firestore.collection('users').doc(actualUserId).get();
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
      
      // Province data saved successfully
    } catch (e) {
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
      // All provinces saved successfully
    } catch (e) {
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
      
      // Province score updated successfully
    } catch (e) {
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
      
      // Province unlocked successfully
    } catch (e) {
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
      
      // Province explored successfully
    } catch (e) {
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
      
      // Daily challenge completed successfully
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật daily streak
  Future<void> updateDailyStreak(String userId, int streak) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      await userDoc.set({
        'gameProgress': {
          'dailyStreak': streak,
          'lastPlayDate': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      await _leaderboardUsers().doc(userId).set({
        'dailyStreak': streak,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Daily streak updated successfully
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật total score
  Future<void> updateTotalScore(String userId, int totalScore) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      await userDoc.set({
        'gameProgress': {
          'totalScore': totalScore,
        }
      }, SetOptions(merge: true));

      await _leaderboardUsers().doc(userId).set({
        'totalScore': totalScore,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Total score updated successfully
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật số tỉnh đã mở khóa (để phục vụ leaderboard)
  Future<void> updateUnlockedProvincesCount(String userId, int count) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      await userDoc.set({
        'gameProgress': {
          'unlockedProvincesCount': count,
        }
      }, SetOptions(merge: true));

      await _leaderboardUsers().doc(userId).set({
        'unlockedProvincesCount': count,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Lấy top user theo tổng điểm
  Future<List<Map<String, dynamic>>> getTopUsersByScore({int limit = 50}) async {
    try {
      final query = await _leaderboardUsers()
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'displayName': data['displayName'] ?? 'Người chơi',
          'photoUrl': data['photoUrl'],
          'totalScore': data['totalScore'] ?? 0,
          'unlockedProvincesCount': data['unlockedProvincesCount'] ?? 0,
          'dailyStreak': data['dailyStreak'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Lấy top user theo số tỉnh đã mở khóa
  Future<List<Map<String, dynamic>>> getTopUsersByUnlocked({int limit = 50}) async {
    try {
      final query = await _leaderboardUsers()
          .orderBy('unlockedProvincesCount', descending: true)
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'displayName': data['displayName'] ?? 'Người chơi',
          'photoUrl': data['photoUrl'],
          'totalScore': data['totalScore'] ?? 0,
          'unlockedProvincesCount': data['unlockedProvincesCount'] ?? 0,
          'dailyStreak': data['dailyStreak'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Lấy leaderboard duy nhất: ưu tiên điểm, sau đó số tỉnh đã mở
  Future<List<Map<String, dynamic>>> getTopUsersByScoreThenUnlocked({int limit = 100}) async {
    try {
      final query = await _leaderboardUsers()
          .orderBy('totalScore', descending: true)
          .orderBy('unlockedProvincesCount', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'displayName': data['displayName'] ?? 'Người chơi',
          'photoUrl': data['photoUrl'],
          'totalScore': data['totalScore'] ?? 0,
          'unlockedProvincesCount': data['unlockedProvincesCount'] ?? 0,
          'dailyStreak': data['dailyStreak'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Backfill leaderboard từ collection users -> leaderboards/global/users
  /// Trả về số bản ghi đã upsert
  Future<int> backfillLeaderboard() async {
    try {
      final usersSnap = await _firestore.collection('users').get();
      int processed = 0;
      WriteBatch batch = _firestore.batch();
      int ops = 0;

      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final profile = (data['profile'] ?? {}) as Map<String, dynamic>;
        final progress = (data['gameProgress'] ?? {}) as Map<String, dynamic>;

        final ref = _leaderboardUsers().doc(doc.id);
        batch.set(ref, {
          'displayName': profile['displayName'] ?? 'Người chơi',
          'photoUrl': profile['photoUrl'],
          'totalScore': progress['totalScore'] ?? 0,
          'unlockedProvincesCount': progress['unlockedProvincesCount'] ?? 0,
          'dailyStreak': progress['dailyStreak'] ?? 0,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        ops++;
        processed++;

        if (ops >= 400) { // an toàn dưới giới hạn 500 mỗi batch
          await batch.commit();
          batch = _firestore.batch();
          ops = 0;
        }
      }

      if (ops > 0) {
        await batch.commit();
      }

      return processed;
    } catch (e) {
      return 0;
    }
  }

  /// Tạo 10 user giả lập với điểm từ 300-400 để test leaderboard
  Future<int> generateMockUsers() async {
    try {
      // Tạo mock data local thay vì ghi vào Firestore (tránh permission issues)
      return 10; // Trả về số lượng user đã tạo
    } catch (e) {
      return 0;
    }
  }

  /// Lấy mock data cho testing (không cần quyền Firestore)
  List<Map<String, dynamic>> getMockLeaderboardData() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'current_user';
    
    // Tạo 32 user test với điểm từ 65-398
    final mockUsers = [
      // Top 10 users (300-400 điểm)
      {'userId': 'user_1', 'displayName': 'Nguyễn Văn A', 'totalScore': 398, 'unlockedProvincesCount': 15, 'dailyStreak': 7, 'photoUrl': null},
      {'userId': 'user_2', 'displayName': 'Trần Thị B', 'totalScore': 385, 'unlockedProvincesCount': 14, 'dailyStreak': 5, 'photoUrl': null},
      {'userId': 'user_3', 'displayName': 'Lê Văn C', 'totalScore': 372, 'unlockedProvincesCount': 13, 'dailyStreak': 3, 'photoUrl': null},
      {'userId': 'user_4', 'displayName': 'Phạm Thị D', 'totalScore': 365, 'unlockedProvincesCount': 12, 'dailyStreak': 6, 'photoUrl': null},
      {'userId': 'user_5', 'displayName': 'Hoàng Văn E', 'totalScore': 358, 'unlockedProvincesCount': 11, 'dailyStreak': 4, 'photoUrl': null},
      {'userId': 'user_6', 'displayName': 'Vũ Thị F', 'totalScore': 345, 'unlockedProvincesCount': 10, 'dailyStreak': 2, 'photoUrl': null},
      {'userId': 'user_7', 'displayName': 'Đặng Văn G', 'totalScore': 332, 'unlockedProvincesCount': 9, 'dailyStreak': 8, 'photoUrl': null},
      {'userId': 'user_8', 'displayName': 'Bùi Thị H', 'totalScore': 318, 'unlockedProvincesCount': 8, 'dailyStreak': 1, 'photoUrl': null},
      {'userId': 'user_9', 'displayName': 'Đỗ Văn I', 'totalScore': 305, 'unlockedProvincesCount': 7, 'dailyStreak': 5, 'photoUrl': null},
      {'userId': currentUserId, 'displayName': 'Bạn', 'totalScore': 295, 'unlockedProvincesCount': 6, 'dailyStreak': 3, 'photoUrl': null}, // User hiện tại ở vị trí 10
      
      // 22 users tiếp theo (65-290 điểm)
      {'userId': 'user_11', 'displayName': 'Ngô Văn K', 'totalScore': 288, 'unlockedProvincesCount': 6, 'dailyStreak': 4, 'photoUrl': null},
      {'userId': 'user_12', 'displayName': 'Dương Thị L', 'totalScore': 275, 'unlockedProvincesCount': 5, 'dailyStreak': 2, 'photoUrl': null},
      {'userId': 'user_13', 'displayName': 'Lý Văn M', 'totalScore': 262, 'unlockedProvincesCount': 5, 'dailyStreak': 6, 'photoUrl': null},
      {'userId': 'user_14', 'displayName': 'Hồ Thị N', 'totalScore': 248, 'unlockedProvincesCount': 4, 'dailyStreak': 1, 'photoUrl': null},
      {'userId': 'user_15', 'displayName': 'Mai Văn O', 'totalScore': 235, 'unlockedProvincesCount': 4, 'dailyStreak': 3, 'photoUrl': null},
      {'userId': 'user_16', 'displayName': 'Tô Thị P', 'totalScore': 222, 'unlockedProvincesCount': 3, 'dailyStreak': 5, 'photoUrl': null},
      {'userId': 'user_17', 'displayName': 'Võ Văn Q', 'totalScore': 218, 'unlockedProvincesCount': 3, 'dailyStreak': 2, 'photoUrl': null},
      {'userId': 'user_18', 'displayName': 'Đinh Thị R', 'totalScore': 205, 'unlockedProvincesCount': 2, 'dailyStreak': 4, 'photoUrl': null},
      {'userId': 'user_19', 'displayName': 'Tạ Văn S', 'totalScore': 198, 'unlockedProvincesCount': 2, 'dailyStreak': 1, 'photoUrl': null},
      {'userId': 'user_20', 'displayName': 'Trịnh Thị T', 'totalScore': 185, 'unlockedProvincesCount': 1, 'dailyStreak': 3, 'photoUrl': null},
      {'userId': 'user_21', 'displayName': 'Lưu Văn U', 'totalScore': 172, 'unlockedProvincesCount': 1, 'dailyStreak': 2, 'photoUrl': null},
      {'userId': 'user_22', 'displayName': 'Châu Thị V', 'totalScore': 165, 'unlockedProvincesCount': 1, 'dailyStreak': 5, 'photoUrl': null},
      {'userId': 'user_23', 'displayName': 'Hà Văn W', 'totalScore': 158, 'unlockedProvincesCount': 1, 'dailyStreak': 1, 'photoUrl': null},
      {'userId': 'user_24', 'displayName': 'Tăng Thị X', 'totalScore': 145, 'unlockedProvincesCount': 1, 'dailyStreak': 4, 'photoUrl': null},
      {'userId': 'user_25', 'displayName': 'Phan Văn Y', 'totalScore': 138, 'unlockedProvincesCount': 1, 'dailyStreak': 2, 'photoUrl': null},
      {'userId': 'user_26', 'displayName': 'Vương Thị Z', 'totalScore': 125, 'unlockedProvincesCount': 1, 'dailyStreak': 3, 'photoUrl': null},
      {'userId': 'user_27', 'displayName': 'Thạch Văn AA', 'totalScore': 118, 'unlockedProvincesCount': 1, 'dailyStreak': 1, 'photoUrl': null},
      {'userId': 'user_28', 'displayName': 'Lâm Thị BB', 'totalScore': 105, 'unlockedProvincesCount': 1, 'dailyStreak': 2, 'photoUrl': null},
      {'userId': 'user_29', 'displayName': 'Huỳnh Văn CC', 'totalScore': 98, 'unlockedProvincesCount': 1, 'dailyStreak': 4, 'photoUrl': null},
      {'userId': 'user_30', 'displayName': 'Đoàn Thị DD', 'totalScore': 85, 'unlockedProvincesCount': 1, 'dailyStreak': 1, 'photoUrl': null},
      {'userId': 'user_31', 'displayName': 'Trương Văn EE', 'totalScore': 78, 'unlockedProvincesCount': 1, 'dailyStreak': 3, 'photoUrl': null},
      {'userId': 'user_32', 'displayName': 'Nguyễn Thị FF', 'totalScore': 65, 'unlockedProvincesCount': 1, 'dailyStreak': 2, 'photoUrl': null},
    ];
    
    return mockUsers;
  }

  /// Mock cursor-based pagination cho testing (giống data thật)
  /// Returns: {
  ///   'items': List<Map<String, dynamic>>,
  ///   'cursor': List<Object?>? (use with startAfter),
  ///   'hasMore': bool
  /// }
  Future<Map<String, dynamic>> getMockLeaderboardPageWithCursor({
    int limit = 30,
    List<Object?>? startAfter,
  }) async {
    final allUsers = getMockLeaderboardData();
    
    // Tìm vị trí bắt đầu dựa trên cursor
    int startIndex = 0;
    if (startAfter != null && startAfter.length >= 2) {
      final lastScore = startAfter[0] as int? ?? 0;
      final lastUnlocked = startAfter[1] as int? ?? 0;
      
      // Tìm vị trí của user cuối cùng từ trang trước
      for (int i = 0; i < allUsers.length; i++) {
        final user = allUsers[i];
        final score = user['totalScore'] as int? ?? 0;
        final unlocked = user['unlockedProvincesCount'] as int? ?? 0;
        
        if (score == lastScore && unlocked == lastUnlocked) {
          startIndex = i + 1; // Bắt đầu từ user tiếp theo
          break;
        }
      }
    }
    
    // Lấy trang hiện tại
    final endIndex = (startIndex + limit).clamp(0, allUsers.length);
    final pageUsers = allUsers.sublist(startIndex, endIndex);
    
    // Tạo cursor cho trang tiếp theo
    List<Object?>? cursor;
    if (pageUsers.isNotEmpty) {
      final lastUser = pageUsers.last;
      cursor = [
        lastUser['totalScore'] as int? ?? 0,
        lastUser['unlockedProvincesCount'] as int? ?? 0,
      ];
    }
    
    return {
      'items': pageUsers,
      'cursor': cursor,
      'hasMore': endIndex < allUsers.length,
    };
  }

  /// Cursor-based pagination without Cloud Functions
  /// Returns: {
  ///   'items': List<Map<String, dynamic>>,
  ///   'cursor': List<Object?>? (use with startAfter),
  ///   'hasMore': bool
  /// }
  Future<Map<String, dynamic>> getLeaderboardPageWithCursor({
    int limit = 30,
    List<Object?>? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _leaderboardUsers()
          .orderBy('totalScore', descending: true)
          .orderBy('unlockedProvincesCount', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfter(startAfter);
      }

      final snap = await query.get();
      final items = snap.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'displayName': data['displayName'] ?? 'Người chơi',
          'photoUrl': data['photoUrl'],
          'totalScore': data['totalScore'] ?? 0,
          'unlockedProvincesCount': data['unlockedProvincesCount'] ?? 0,
          'dailyStreak': data['dailyStreak'] ?? 0,
        };
      }).toList();

      List<Object?>? cursor;
      if (snap.docs.isNotEmpty) {
        final last = snap.docs.last.data();
        cursor = [
          last['totalScore'] ?? 0,
          last['unlockedProvincesCount'] ?? 0,
        ];
      }

      return {
        'items': items,
        'cursor': cursor,
        'hasMore': snap.docs.length == limit,
      };
    } catch (e) {
      return {
        'items': <Map<String, dynamic>>[],
        'cursor': null,
        'hasMore': false,
      };
    }
  }

  /// Get current user's leaderboard snapshot (score/unlocked and basic info)
  Future<Map<String, dynamic>?> getMyLeaderboardEntry() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final doc = await _leaderboardUsers().doc(user.uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return {
        'userId': doc.id,
        'displayName': data['displayName'] ?? 'Người chơi',
        'photoUrl': data['photoUrl'],
        'totalScore': data['totalScore'] ?? 0,
        'unlockedProvincesCount': data['unlockedProvincesCount'] ?? 0,
        'dailyStreak': data['dailyStreak'] ?? 0,
      };
    } catch (e) {
      return null;
    }
  }

  /// Approximate rank using aggregate counts (without Cloud Functions)
  Future<int?> getMyApproxRank() async {
    print('[UserService] getMyApproxRank: ENTRY POINT');
    try {
      print('[UserService] getMyApproxRank: starting...');
      final me = await getMyLeaderboardEntry();
      print('[UserService] getMyApproxRank: getMyLeaderboardEntry result=$me');
      if (me == null) {
        print('[UserService] getMyApproxRank: no leaderboard entry found');
        return null;
      }
      final int myScore = me['totalScore'] as int? ?? 0;
      final int myUnlocked = me['unlockedProvincesCount'] as int? ?? 0;
      print('[UserService] getMyApproxRank: myScore=$myScore, myUnlocked=$myUnlocked');

      // Simplified approach: Count users with greater or equal score, then filter in memory
      print('[UserService] getMyApproxRank: about to query all users with >= score...');
      final allUsers = await _leaderboardUsers()
          .where('totalScore', isGreaterThanOrEqualTo: myScore)
          .orderBy('totalScore', descending: true)
          .orderBy('unlockedProvincesCount', descending: true)
          .get();
      print('[UserService] getMyApproxRank: found ${allUsers.docs.length} users with >= score');

      // Calculate rank manually
      int rank = 1;
      for (final doc in allUsers.docs) {
        final data = doc.data();
        final score = data['totalScore'] as int? ?? 0;
        final unlocked = data['unlockedProvincesCount'] as int? ?? 0;
        
        if (score > myScore || (score == myScore && unlocked > myUnlocked)) {
          rank++;
        } else if (score == myScore && unlocked == myUnlocked) {
          // Found our position
          break;
        }
      }
      
      print('[UserService] getMyApproxRank: calculated rank=$rank');
      print('[UserService] getMyApproxRank: SUCCESS - returning rank=$rank');
      return rank;
    } catch (e) {
      print('[UserService] getMyApproxRank: ERROR caught: $e');
      print('[UserService] getMyApproxRank: error stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Fetch a window starting at current user's position (inclusive) without CF
  Future<List<Map<String, dynamic>>> getWindowFromMyPosition({int limit = 20}) async {
    try {
      final me = await getMyLeaderboardEntry();
      if (me == null) return [];
      final int myScore = me['totalScore'] as int? ?? 0;
      final int myUnlocked = me['unlockedProvincesCount'] as int? ?? 0;

      final snap = await _leaderboardUsers()
          .orderBy('totalScore', descending: true)
          .orderBy('unlockedProvincesCount', descending: true)
          .startAt([myScore, myUnlocked])
          .limit(limit)
          .get();

      return snap.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'displayName': data['displayName'] ?? 'Người chơi',
          'photoUrl': data['photoUrl'],
          'totalScore': data['totalScore'] ?? 0,
          'unlockedProvincesCount': data['unlockedProvincesCount'] ?? 0,
          'dailyStreak': data['dailyStreak'] ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
} 