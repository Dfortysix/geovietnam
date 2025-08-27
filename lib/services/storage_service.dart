import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload ảnh avatar lên Firebase Storage
  Future<String> uploadAvatarImage(File imageFile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Tạo tên file unique
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final storageRef = _storage.ref().child('avatars/$fileName');

      // Upload file
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Theo dõi tiến trình upload
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Chờ upload hoàn thành
      final snapshot = await uploadTask;
      
      // Lấy download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Avatar uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Xóa ảnh avatar cũ (nếu có)
  Future<void> deleteOldAvatar(String? oldPhotoUrl) async {
    try {
      if (oldPhotoUrl == null || oldPhotoUrl.isEmpty) return;

      // Kiểm tra xem URL có phải từ Firebase Storage không
      if (!oldPhotoUrl.contains('firebasestorage.googleapis.com')) return;

      // Lấy reference từ URL
      final ref = _storage.refFromURL(oldPhotoUrl);
      
      // Xóa file
      await ref.delete();
      print('Old avatar deleted successfully');
    } catch (e) {
      print('Error deleting old avatar: $e');
      // Không throw error vì đây không phải lỗi nghiêm trọng
    }
  }

  /// Compress và resize ảnh trước khi upload
  Future<File> compressImage(File imageFile) async {
    try {
      // TODO: Implement image compression if needed
      // For now, return the original file
      return imageFile;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile;
    }
  }

  /// Kiểm tra kích thước file
  bool isValidFileSize(File file) {
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    return file.lengthSync() <= maxSizeInBytes;
  }

  /// Kiểm tra định dạng file
  bool isValidImageFormat(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp'].contains(extension);
  }
}

