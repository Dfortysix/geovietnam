import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../widgets/user_avatar_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isSaving = false;
  String? _currentDisplayName;
  String? _currentPhotoUrl;
  File? _selectedImage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final profile = await _userService.getUserProfile(userId);
        if (profile != null) {
          setState(() {
            _currentDisplayName = profile['displayName'] as String?;
            _currentPhotoUrl = profile['photoUrl'] as String?;
            _displayNameController.text = _currentDisplayName ?? '';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải thông tin hồ sơ: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      // Kiểm tra nếu đang chạy trên web
      if (kIsWeb) {
        setState(() {
          _errorMessage = 'Tính năng chọn ảnh chưa hỗ trợ trên web. Vui lòng sử dụng ứng dụng mobile.';
        });
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chọn ảnh: $e';
      });
      print('Error picking image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Kiểm tra nếu đang chạy trên web
      if (kIsWeb) {
        setState(() {
          _errorMessage = 'Tính năng chụp ảnh chưa hỗ trợ trên web. Vui lòng sử dụng ứng dụng mobile.';
        });
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chụp ảnh: $e';
      });
      print('Error taking photo: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_displayNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Tên hiển thị không được để trống';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // TODO: Implement image upload to Firebase Storage
      // For now, we'll just update the display name
      String? newPhotoUrl = _currentPhotoUrl;
      
      // If user selected a new image, upload it
      if (_selectedImage != null) {
        // TODO: Upload image to Firebase Storage and get URL
        // newPhotoUrl = await _uploadImage(_selectedImage!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tính năng upload ảnh sẽ sớm ra mắt!'),
            backgroundColor: AppTheme.primaryOrange,
          ),
        );
      }

      // Update profile in Firestore
      await _userService.updateUserProfile(
        userId: userId,
        displayName: _displayNameController.text.trim(),
        photoUrl: newPhotoUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể cập nhật hồ sơ: $e';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryOrange,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Lưu',
                style: TextStyle(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryOrange,
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error message
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Avatar section
                      Center(
                        child: Column(
                          children: [
                            // Current avatar
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  UserAvatarWidget(
                                    photoUrl: _selectedImage != null ? null : _currentPhotoUrl,
                                    size: 120,
                                    borderColor: Colors.white,
                                    borderWidth: 4,
                                    imageFile: _selectedImage,
                                  ),
                                  // Edit overlay
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryOrange,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                                                         // Image picker buttons
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 ElevatedButton.icon(
                                   onPressed: kIsWeb ? null : _pickImage,
                                   icon: const Icon(Icons.photo_library),
                                   label: const Text('Thư viện'),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: kIsWeb ? Colors.grey : AppTheme.primaryOrange,
                                     foregroundColor: Colors.white,
                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(20),
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 ElevatedButton.icon(
                                   onPressed: kIsWeb ? null : _takePhoto,
                                   icon: const Icon(Icons.camera_alt),
                                   label: const Text('Chụp ảnh'),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: kIsWeb ? Colors.grey : AppTheme.secondaryYellow,
                                     foregroundColor: Colors.white,
                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(20),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                             
                             // Thông báo cho web
                             if (kIsWeb)
                               Padding(
                                 padding: const EdgeInsets.only(top: 12),
                                 child: Text(
                                   'Tính năng chọn ảnh chỉ khả dụng trên ứng dụng mobile',
                                   style: TextStyle(
                                     fontSize: 12,
                                     color: Colors.grey[600],
                                     fontStyle: FontStyle.italic,
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                               ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Display name section
                      const Text(
                        'Tên hiển thị',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: TextField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            hintText: 'Nhập tên hiển thị',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Info section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tên hiển thị sẽ được sử dụng trong bảng xếp hạng và các tính năng khác của ứng dụng.',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
