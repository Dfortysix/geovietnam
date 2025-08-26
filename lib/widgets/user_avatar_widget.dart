import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class UserAvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final File? imageFile;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const UserAvatarWidget({
    super.key,
    this.photoUrl,
    this.imageFile,
    this.size = 60,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(
                  color: borderColor!,
                  width: borderWidth,
                )
              : null,
        ),
        child: ClipOval(
          child: _buildAvatarContent(),
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    // Ưu tiên file local nếu có
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }

    // Sau đó là URL từ network
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildDefaultAvatar(),
      );
    }

    // Fallback về default avatar
    return _buildDefaultAvatar();
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.primaryOrange,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryOrange, AppTheme.secondaryYellow],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }
}

// Widget hiển thị avatar với tên
class UserAvatarWithNameWidget extends StatelessWidget {
  final String? photoUrl;
  final String? displayName;
  final String? email;
  final double avatarSize;
  final bool showEmail;

  const UserAvatarWithNameWidget({
    super.key,
    this.photoUrl,
    this.displayName,
    this.email,
    this.avatarSize = 40,
    this.showEmail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatarWidget(
          photoUrl: photoUrl,
          size: avatarSize,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName ?? 'Người chơi',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (showEmail && email != null)
                Text(
                  email!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
} 