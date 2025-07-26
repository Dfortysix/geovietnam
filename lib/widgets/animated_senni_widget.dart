import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class AnimatedSenniWidget extends StatefulWidget {
  final String? message;
  final VoidCallback? onTap;
  final double size;
  final String mood; // 'happy', 'excited', 'thinking', 'sad', 'celebrating'
  final bool isAnimating;

  const AnimatedSenniWidget({
    Key? key,
    this.message,
    this.onTap,
    this.size = 100,
    this.mood = 'happy',
    this.isAnimating = false,
  }) : super(key: key);

  @override
  State<AnimatedSenniWidget> createState() => _AnimatedSenniWidgetState();
}

class _AnimatedSenniWidgetState extends State<AnimatedSenniWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _wiggleController;
  late AnimationController _pulseController;
  late AnimationController _celebrateController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _wiggleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _celebrateAnimation;

  @override
  void initState() {
    super.initState();
    
    // Bounce animation (nhảy lên xuống)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Wiggle animation (lắc lư)
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _wiggleAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _wiggleController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation (phóng to thu nhỏ)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Celebrate animation (xoay và nhảy)
    _celebrateController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _celebrateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrateController,
      curve: Curves.elasticOut,
    ));

    _startIdleAnimation();
  }

  void _startIdleAnimation() {
    // Bounce nhẹ nhàng liên tục
    _bounceController.repeat(reverse: true);
    
    // Wiggle thỉnh thoảng
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _wiggleController.forward().then((_) {
          _wiggleController.reverse();
        });
        _startIdleAnimation();
      }
    });
  }

  void _startCelebration() {
    _celebrateController.forward().then((_) {
      _celebrateController.reverse();
    });
    _pulseController.repeat(reverse: true);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedSenniWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startCelebration();
    }
    
    if (widget.mood != oldWidget.mood) {
      // Thay đổi mood thì wiggle một chút
      _wiggleController.forward().then((_) {
        _wiggleController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _wiggleController.dispose();
    _pulseController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _bounceController,
          _wiggleController,
          _pulseController,
          _celebrateController,
        ]),
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(
                0.0,
                -_bounceAnimation.value * 8.0,
              )
              ..rotateZ(_wiggleAnimation.value)
              ..scale(_pulseAnimation.value),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getMoodColor().withOpacity(0.3),
                    blurRadius: 20 + _pulseAnimation.value * 10,
                    spreadRadius: 5 + _pulseAnimation.value * 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main body với gradient động
                  Center(
                    child: Container(
                      width: widget.size * 0.9,
                      height: widget.size * 0.9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _getAnimatedGradient(),
                        border: Border.all(
                          color: _getMoodColor(),
                          width: 3,
                        ),
                      ),
                      child: _buildSenniFace(),
                    ),
                  ),

                  // Hat với animation
                  Positioned(
                    top: widget.size * 0.05 - _bounceAnimation.value * 2,
                    left: widget.size * 0.2,
                    child: Transform.rotate(
                      angle: _wiggleAnimation.value * 0.3,
                      child: Container(
                        width: widget.size * 0.6,
                        height: widget.size * 0.25,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513),
                          borderRadius: BorderRadius.circular(widget.size * 0.3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bag với animation
                  Positioned(
                    bottom: widget.size * 0.1,
                    right: widget.size * 0.1,
                    child: Transform.rotate(
                      angle: _wiggleAnimation.value * 0.2,
                      child: Container(
                        width: widget.size * 0.3,
                        height: widget.size * 0.4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.map,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  // Sparkles khi celebrate
                  if (widget.isAnimating)
                    ..._buildSparkles(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSenniFace() {
    return Stack(
      children: [
        // Eyes với blink animation
        Positioned(
          top: widget.size * 0.25,
          left: widget.size * 0.25,
          child: _buildEye(widget.size * 0.15),
        ),
        Positioned(
          top: widget.size * 0.25,
          right: widget.size * 0.25,
          child: _buildEye(widget.size * 0.15),
        ),

        // Mouth với animation
        Positioned(
          bottom: widget.size * 0.3,
          left: 0.0,
          right: 0.0,
          child: _buildMouth(),
        ),

        // Cheeks với pulse
        Positioned(
          bottom: widget.size * 0.35,
          left: widget.size * 0.15,
          child: _buildCheek(),
        ),
        Positioned(
          bottom: widget.size * 0.35,
          right: widget.size * 0.15,
          child: _buildCheek(),
        ),
      ],
    );
  }

  Widget _buildEye(double eyeSize) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Container(
          width: eyeSize,
          height: eyeSize * (0.3 + 0.7 * _bounceController.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getMoodColor(),
          ),
          child: Center(
            child: Container(
              width: eyeSize * 0.5,
              height: eyeSize * 0.5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMouth() {
    IconData mouthIcon;
    double mouthSize = widget.size * 0.2;

    switch (widget.mood) {
      case 'happy':
        mouthIcon = Icons.sentiment_satisfied;
        break;
      case 'excited':
        mouthIcon = Icons.sentiment_very_satisfied;
        break;
      case 'thinking':
        mouthIcon = Icons.sentiment_neutral;
        break;
      case 'sad':
        mouthIcon = Icons.sentiment_dissatisfied;
        break;
      case 'celebrating':
        mouthIcon = Icons.sentiment_very_satisfied;
        break;
      default:
        mouthIcon = Icons.sentiment_satisfied;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + _pulseController.value * 0.1,
          child: Icon(
            mouthIcon,
            size: mouthSize,
            color: _getMoodColor(),
          ),
        );
      },
    );
  }

  Widget _buildCheek() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: widget.size * 0.08,
          height: widget.size * 0.08,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.pink.withOpacity(0.3 + _pulseController.value * 0.2),
          ),
        );
      },
    );
  }

  List<Widget> _buildSparkles() {
    List<Widget> sparkles = [];
    for (int i = 0; i < 8; i++) {
      sparkles.add(
        Positioned(
          left: widget.size * 0.2 + (i * 0.1) * widget.size,
          top: widget.size * 0.1 + math.sin(i * 0.5) * widget.size * 0.3,
          child: AnimatedBuilder(
            animation: _celebrateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _celebrateAnimation.value * 2 * math.pi,
                child: Transform.scale(
                  scale: _celebrateAnimation.value,
                  child: Icon(
                    Icons.star,
                    color: Colors.yellow.withOpacity(_celebrateAnimation.value),
                    size: 12,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return sparkles;
  }

  LinearGradient _getAnimatedGradient() {
    Color primaryColor = _getMoodColor();
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withOpacity(0.8 + _pulseAnimation.value * 0.1),
        primaryColor.withOpacity(0.6 + _pulseAnimation.value * 0.1),
      ],
    );
  }

  Color _getMoodColor() {
    switch (widget.mood) {
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

// Container widget với animation
class AnimatedSenniContainer extends StatefulWidget {
  final String situation;
  final String? customMessage;
  final String? provinceName;
  final VoidCallback? onSenniTap;
  final bool showSenni;
  final double senniSize;
  final Duration messageDuration;
  final bool autoHide;

  const AnimatedSenniContainer({
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
  State<AnimatedSenniContainer> createState() => _AnimatedSenniContainerState();
}

class _AnimatedSenniContainerState extends State<AnimatedSenniContainer>
    with TickerProviderStateMixin {
  bool _showMessage = true;
  String _currentMessage = '';
  bool _isAnimating = false;
  
  late AnimationController _messageController;
  late Animation<double> _messageAnimation;

  @override
  void initState() {
    super.initState();
    
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _messageAnimation = CurvedAnimation(
      parent: _messageController,
      curve: Curves.elasticOut,
    );
    
    _updateMessage();
    _messageController.forward();
    
    if (widget.autoHide && widget.messageDuration.inSeconds > 0) {
      Future.delayed(widget.messageDuration, () {
        if (mounted) {
          _messageController.reverse();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _showMessage = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedSenniContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.situation != widget.situation ||
        oldWidget.customMessage != widget.customMessage ||
        oldWidget.provinceName != widget.provinceName) {
      _updateMessage();
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    setState(() {
      _isAnimating = true;
      _showMessage = true;
    });
    
    _messageController.forward();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
    
    if (widget.autoHide && widget.messageDuration.inSeconds > 0) {
      Future.delayed(widget.messageDuration, () {
        if (mounted) {
          _messageController.reverse();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _showMessage = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
          // Message bubble với animation
          if (_showMessage && _currentMessage.isNotEmpty)
            ScaleTransition(
              scale: _messageAnimation,
              child: Container(
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
            ),

          // Senni character với animation
          AnimatedSenniWidget(
            message: null,
            onTap: widget.onSenniTap ?? _onSenniTap,
            size: widget.senniSize,
            mood: _getMoodForSituation(),
            isAnimating: _isAnimating,
          ),
        ],
      ),
    );
  }

  void _onSenniTap() {
    _triggerAnimation();
  }
}

// Helper class để dễ dàng sử dụng
class AnimatedSenniHelper {
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
        AnimatedSenniContainer(
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