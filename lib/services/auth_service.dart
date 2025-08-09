import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'google_play_games_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GooglePlayGamesService _googleService = GooglePlayGamesService();

  /// Kiểm tra user đã đăng nhập chưa
  bool get isLoggedIn {
    return _auth.currentUser != null && _googleService.isSignedIn;
  }

  /// Lấy thông tin user hiện tại
  User? get currentUser => _auth.currentUser;

  /// Lấy thông tin Google user
  GoogleSignInAccount? get currentGoogleUser => _googleService.currentUser;

  /// Refresh trạng thái đăng nhập
  Future<void> refreshLoginStatus() async {
    await _googleService.refreshSignInStatus();
    notifyListeners();
  }

  /// Hiển thị popup yêu cầu đăng nhập
  static Future<bool> showLoginRequiredDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.login,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Yêu cầu đăng nhập',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Để chơi game và lưu tiến trình, bạn cần đăng nhập bằng tài khoản Google.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Lợi ích khi đăng nhập:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text('• Lưu tiến trình game trên cloud'),
              Text('• Đồng bộ dữ liệu giữa các thiết bị'),
              Text('• Tham gia bảng xếp hạng'),
              Text('• Nhận thành tích và phần thưởng'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Không đăng nhập
              },
              child: const Text(
                'Để sau',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true); // Đồng ý đăng nhập
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đăng nhập ngay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Refresh UI khi trạng thái đăng nhập thay đổi
  void refreshUI() {
    notifyListeners();
  }

  /// Kiểm tra và yêu cầu đăng nhập nếu cần
  static Future<bool> requireLogin(BuildContext context) async {
    final authService = AuthService();
    
    if (!authService.isLoggedIn) {
      final shouldLogin = await showLoginRequiredDialog(context);
      if (shouldLogin) {
        // Thực hiện đăng nhập
        final success = await authService._googleService.signIn();
        if (success) {
          // Refresh UI
          authService.refreshUI();
          
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Đăng nhập thành công! Chào mừng ${authService.currentGoogleUser?.displayName ?? 'người chơi'}'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          return true;
        } else {
          // Hiển thị thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Đăng nhập thất bại. Vui lòng thử lại.'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return false;
        }
      }
      return false;
    }
    return true; // Đã đăng nhập
  }
} 