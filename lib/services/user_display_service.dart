import 'user_service.dart';
import 'auth_service.dart';

class UserDisplayService {
  static final UserDisplayService _instance = UserDisplayService._internal();
  factory UserDisplayService() => _instance;
  UserDisplayService._internal();

  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  /// Lấy thông tin hiển thị của user với logic ưu tiên:
  /// 1. Custom profile (từ Firestore) - ưu tiên cao nhất
  /// 2. Google profile (từ Google Sign-In) - ưu tiên thứ hai
  /// 3. Default values - fallback
  Future<UserDisplayInfo> getUserDisplayInfo() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        return UserDisplayInfo.defaultInfo();
      }

      // 1. Thử lấy custom profile từ Firestore
      final customProfile = await _userService.getUserProfile(userId);
      if (customProfile != null) {
        final customDisplayName = customProfile['displayName'] as String?;
        final customPhotoUrl = customProfile['photoUrl'] as String?;
        
        // Nếu có custom displayName, sử dụng nó
        if (customDisplayName != null && customDisplayName.isNotEmpty) {
          return UserDisplayInfo(
            displayName: customDisplayName,
            photoUrl: customPhotoUrl,
            email: customProfile['email'] as String?,
            source: UserDisplaySource.custom,
          );
        }
      }

      // 2. Fallback về Google profile
      final googleUser = _authService.currentGoogleUser;
      if (googleUser != null && googleUser.displayName != null) {
        return UserDisplayInfo(
          displayName: googleUser.displayName!,
          photoUrl: googleUser.photoUrl,
          email: googleUser.email,
          source: UserDisplaySource.google,
        );
      }

      // 3. Fallback về default
      return UserDisplayInfo.defaultInfo();
    } catch (e) {
      // Error getting user display info
      return UserDisplayInfo.defaultInfo();
    }
  }

  /// Lấy display name với logic ưu tiên
  Future<String> getDisplayName() async {
    final displayInfo = await getUserDisplayInfo();
    return displayInfo.displayName;
  }

  /// Lấy photo URL với logic ưu tiên
  Future<String?> getPhotoUrl() async {
    final displayInfo = await getUserDisplayInfo();
    return displayInfo.photoUrl;
  }

  /// Lấy email
  Future<String?> getEmail() async {
    final displayInfo = await getUserDisplayInfo();
    return displayInfo.email;
  }

  /// Kiểm tra xem user có custom profile không
  Future<bool> hasCustomProfile() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return false;

      final customProfile = await _userService.getUserProfile(userId);
      if (customProfile == null) return false;

      final customDisplayName = customProfile['displayName'] as String?;
      return customDisplayName != null && customDisplayName.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Refresh user display info (có thể gọi khi có thay đổi)
  Future<void> refreshUserDisplayInfo() async {
    // Có thể implement cache invalidation ở đây nếu cần
  }
}

/// Thông tin hiển thị của user
class UserDisplayInfo {
  final String displayName;
  final String? photoUrl;
  final String? email;
  final UserDisplaySource source;

  const UserDisplayInfo({
    required this.displayName,
    this.photoUrl,
    this.email,
    required this.source,
  });

  factory UserDisplayInfo.defaultInfo() {
    return const UserDisplayInfo(
      displayName: 'Người chơi',
      photoUrl: null,
      email: null,
      source: UserDisplaySource.defaultValue,
    );
  }

  @override
  String toString() {
    return 'UserDisplayInfo(displayName: $displayName, photoUrl: $photoUrl, email: $email, source: $source)';
  }
}

/// Nguồn của thông tin hiển thị
enum UserDisplaySource {
  custom,      // Từ custom profile (Firestore)
  google,      // Từ Google account
  defaultValue // Default values
}
