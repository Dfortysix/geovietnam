import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ImageSenniWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onTap;
  final double size;
  final String mood; // 'happy', 'excited', 'thinking', 'sad', 'celebrating'

  const ImageSenniWidget({
    Key? key,
    this.message,
    this.onTap,
    this.size = 100,
    this.mood = 'happy',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getMoodColor().withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/senni.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback nếu ảnh không load được
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _getMoodGradient(),
                ),
                child: const Icon(
                  Icons.face,
                  color: Colors.white,
                  size: 50,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  LinearGradient _getMoodGradient() {
    Color primaryColor = _getMoodColor();
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withOpacity(0.8),
        primaryColor.withOpacity(0.6),
      ],
    );
  }

  Color _getMoodColor() {
    switch (mood) {
      case 'happy':
        return Colors.pink.shade300;
      case 'excited':
        return Colors.orange.shade400;
      case 'thinking':
        return Colors.blue.shade300;
      case 'sad':
        return Colors.grey.shade400;
      case 'celebrating':
        return Colors.purple.shade400;
      default:
        return Colors.pink.shade300;
    }
  }
}

// Container widget sử dụng ảnh Senni
class ImageSenniContainer extends StatefulWidget {
  final String situation;
  final String? customMessage;
  final String? provinceName;
  final VoidCallback? onSenniTap;
  final bool showSenni;
  final double senniSize;
  final Duration messageDuration;
  final bool autoHide;

  const ImageSenniContainer({
    Key? key,
    required this.situation,
    this.customMessage,
    this.provinceName,
    this.onSenniTap,
    this.showSenni = true,
    this.senniSize = 100,
    this.messageDuration = const Duration(seconds: 3),
    this.autoHide = true,
  }) : super(key: key);

  @override
  State<ImageSenniContainer> createState() => _ImageSenniContainerState();
}

class _ImageSenniContainerState extends State<ImageSenniContainer> {
  bool _showMessage = true;
  String _currentMessage = '';

  @override
  void initState() {
    super.initState();
    _updateMessage();
    
    if (widget.autoHide && widget.messageDuration.inSeconds > 0) {
      Future.delayed(widget.messageDuration, () {
        if (mounted) {
          setState(() {
            _showMessage = false;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(ImageSenniContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.situation != widget.situation ||
        oldWidget.customMessage != widget.customMessage ||
        oldWidget.provinceName != widget.provinceName) {
      _updateMessage();
      setState(() {
        _showMessage = true;
      });
      
      if (widget.autoHide && widget.messageDuration.inSeconds > 0) {
        Future.delayed(widget.messageDuration, () {
          if (mounted) {
            setState(() {
              _showMessage = false;
            });
          }
        });
      }
    }
  }

  void _updateMessage() {
    if (widget.customMessage != null) {
      _currentMessage = widget.customMessage!;
    } else {
      switch (widget.situation) {
        case 'greeting':
          _currentMessage = "🗺️ Cùng Senni khám phá đất Việt yêu thương nào!";
          break;
        case 'correct_answer':
          _currentMessage = "🎉 Tuyệt vời! Bạn thật thông minh!";
          break;
        case 'wrong_answer':
          _currentMessage = "💪 Không sao đâu! Hãy thử lại nhé!";
          break;
        case 'province_unlock':
          if (widget.provinceName != null) {
            _currentMessage = "🎉 Chúc mừng bạn đã mở khóa ${widget.provinceName}!";
          } else {
            _currentMessage = "🏆 Chúc mừng! Bạn đã đạt được thành tích mới!";
          }
          break;
        case 'achievement':
          _currentMessage = "🌟 Tuyệt vời! Senni rất tự hào về bạn!";
          break;
        case 'game_end':
          _currentMessage = "🌸 Cảm ơn bạn đã chơi cùng Senni!";
          break;
        default:
          _currentMessage = "🗺️ Cùng Senni khám phá đất Việt yêu thương nào!";
      }
    }
  }

  String _getMoodForSituation() {
    switch (widget.situation) {
      case 'greeting':
        return 'happy';
      case 'correct_answer':
        return 'excited';
      case 'wrong_answer':
        return 'thinking';
      case 'achievement':
        return 'celebrating';
      case 'game_end':
        return 'happy';
      default:
        return 'happy';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showSenni) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Message bubble
          if (_showMessage && _currentMessage.isNotEmpty)
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppTheme.lightOrange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Arrow pointing to Senni
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 0,
                      height: 0,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.white, width: 8),
                          right: BorderSide(color: Colors.transparent, width: 8),
                          top: BorderSide(color: Colors.transparent, width: 8),
                          bottom: BorderSide(color: Colors.transparent, width: 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Message text
                  Text(
                    _currentMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Senni character with image
          ImageSenniWidget(
            message: null,
            onTap: widget.onSenniTap ?? _onSenniTap,
            size: widget.senniSize,
            mood: _getMoodForSituation(),
          ),
        ],
      ),
    );
  }

  void _onSenniTap() {
    setState(() {
      _showMessage = !_showMessage;
    });

    if (_showMessage && widget.autoHide && widget.messageDuration.inSeconds > 0) {
      Future.delayed(widget.messageDuration, () {
        if (mounted) {
          setState(() {
            _showMessage = false;
          });
        }
      });
    }
  }
}

// Helper class để dễ dàng sử dụng
class ImageSenniHelper {
  static Widget showSenniInScreen({
    required Widget child,
    required String situation,
    String? customMessage,
    String? provinceName,
    VoidCallback? onSenniTap,
    bool showSenni = true,
    double senniSize = 100,
    Duration messageDuration = const Duration(seconds: 3),
    bool autoHide = true,
  }) {
    return Stack(
      children: [
        child,
        ImageSenniContainer(
          situation: situation,
          customMessage: customMessage,
          provinceName: provinceName,
          onSenniTap: onSenniTap,
          showSenni: showSenni,
          senniSize: senniSize,
          messageDuration: messageDuration,
          autoHide: autoHide,
        ),
      ],
    );
  }
} 