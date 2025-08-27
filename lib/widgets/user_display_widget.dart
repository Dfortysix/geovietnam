import 'package:flutter/material.dart';
import '../services/user_display_service.dart';
import 'user_avatar_widget.dart';

/// Widget hiển thị thông tin user với logic ưu tiên:
/// 1. Custom profile (từ Firestore)
/// 2. Google profile (từ Google Sign-In)
/// 3. Default values
class UserDisplayWidget extends StatefulWidget {
  final double avatarSize;
  final bool showEmail;
  final bool showSource;
  final VoidCallback? onTap;

  const UserDisplayWidget({
    super.key,
    this.avatarSize = 40,
    this.showEmail = true,
    this.showSource = false,
    this.onTap,
  });

  @override
  State<UserDisplayWidget> createState() => _UserDisplayWidgetState();
}

class _UserDisplayWidgetState extends State<UserDisplayWidget> {
  final UserDisplayService _userDisplayService = UserDisplayService();
  UserDisplayInfo? _displayInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDisplayInfo();
  }

  Future<void> _loadUserDisplayInfo() async {
    try {
      final displayInfo = await _userDisplayService.getUserDisplayInfo();
      if (mounted) {
        setState(() {
          _displayInfo = displayInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _displayInfo = UserDisplayInfo.defaultInfo();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Row(
        children: [
          SizedBox(
            width: widget.avatarSize,
            height: widget.avatarSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 16,
                  child: LinearProgressIndicator(),
                ),
                SizedBox(height: 4),
                SizedBox(
                  height: 12,
                  child: LinearProgressIndicator(),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final displayInfo = _displayInfo ?? UserDisplayInfo.defaultInfo();

    return GestureDetector(
      onTap: widget.onTap,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 4,
        children: [
          UserAvatarWidget(
            photoUrl: displayInfo.photoUrl,
            size: widget.avatarSize,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayInfo.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    softWrap: false,
                  ),
                  if (widget.showSource) ...[
                    const SizedBox(width: 6),
                    _buildSourceIndicator(displayInfo.source),
                  ],
                ],
              ),
              if (widget.showEmail && displayInfo.email != null) ...[
                const SizedBox(height: 2),
                Text(
                  displayInfo.email!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  softWrap: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceIndicator(UserDisplaySource source) {
    IconData icon;
    Color color;
    String tooltip;

    switch (source) {
      case UserDisplaySource.custom:
        icon = Icons.edit;
        color = Colors.blue;
        tooltip = 'Tùy chỉnh';
        break;
      case UserDisplaySource.google:
        icon = Icons.account_circle;
        color = Colors.green;
        tooltip = 'Google';
        break;
      case UserDisplaySource.defaultValue:
        icon = Icons.person;
        color = Colors.grey;
        tooltip = 'Mặc định';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: 14,
        color: color,
      ),
    );
  }
}

/// Widget hiển thị chỉ avatar với logic ưu tiên
class UserAvatarDisplayWidget extends StatefulWidget {
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const UserAvatarDisplayWidget({
    super.key,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
  });

  @override
  State<UserAvatarDisplayWidget> createState() => _UserAvatarDisplayWidgetState();
}

class _UserAvatarDisplayWidgetState extends State<UserAvatarDisplayWidget> {
  final UserDisplayService _userDisplayService = UserDisplayService();
  String? _photoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotoUrl();
  }

  Future<void> _loadPhotoUrl() async {
    try {
      final photoUrl = await _userDisplayService.getPhotoUrl();
      if (mounted) {
        setState(() {
          _photoUrl = photoUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return UserAvatarWidget(
      photoUrl: _photoUrl,
      size: widget.size,
      borderColor: widget.borderColor,
      borderWidth: widget.borderWidth,
      onTap: widget.onTap,
    );
  }
}

/// Widget hiển thị chỉ tên với logic ưu tiên
class UserNameDisplayWidget extends StatefulWidget {
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;

  const UserNameDisplayWidget({
    super.key,
    this.style,
    this.overflow,
    this.maxLines,
    this.textAlign,
  });

  @override
  State<UserNameDisplayWidget> createState() => _UserNameDisplayWidgetState();
}

class _UserNameDisplayWidgetState extends State<UserNameDisplayWidget> {
  final UserDisplayService _userDisplayService = UserDisplayService();
  String _displayName = 'Người chơi';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    try {
      final displayName = await _userDisplayService.getDisplayName();
      if (mounted) {
        setState(() {
          _displayName = displayName;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.style?.fontSize ?? 16,
        child: const LinearProgressIndicator(),
      );
    }

    return Text(
      _displayName,
      style: widget.style,
      overflow: widget.overflow,
      maxLines: widget.maxLines,
      textAlign: widget.textAlign,
    );
  }
}

