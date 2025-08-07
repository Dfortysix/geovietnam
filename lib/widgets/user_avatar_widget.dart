import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final String? displayName;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatarWidget({
    super.key,
    this.photoUrl,
    this.displayName,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderColor = borderColor ?? Colors.blue;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: defaultBorderColor,
          width: borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((size - borderWidth) / 2),
        child: photoUrl != null
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: size * 0.4,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: size * 0.4,
                  ),
                ),
              )
            : Container(
                color: defaultBorderColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: defaultBorderColor,
                  size: size * 0.6,
                ),
              ),
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