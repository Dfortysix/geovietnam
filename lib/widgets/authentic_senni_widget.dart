import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class AuthenticSenniWidget extends StatefulWidget {
  final String? message;
  final VoidCallback? onTap;
  final double size;
  final String mood; // 'happy', 'excited', 'thinking', 'sad', 'celebrating'
  final bool isAnimating;

  const AuthenticSenniWidget({
    Key? key,
    this.message,
    this.onTap,
    this.size = 100,
    this.mood = 'happy',
    this.isAnimating = false,
  }) : super(key: key);

  @override
  State<AuthenticSenniWidget> createState() => _AuthenticSenniWidgetState();
}

class _AuthenticSenniWidgetState extends State<AuthenticSenniWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _wiggleController;
  late AnimationController _pulseController;
  late AnimationController _celebrateController;
  late AnimationController _waveController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _wiggleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _celebrateAnimation;
  late Animation<double> _waveAnimation;

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

    // Wave animation (vẫy tay)
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _startIdleAnimation();
  }

  void _startIdleAnimation() {
    // Bounce nhẹ nhàng liên tục
    _bounceController.repeat(reverse: true);
    
    // Wave tay liên tục
    _waveController.repeat(reverse: true);
    
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
  void didUpdateWidget(AuthenticSenniWidget oldWidget) {
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
    _waveController.dispose();
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
          _waveController,
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
              height: widget.size * 1.4, // Cao hơn để chứa toàn bộ cơ thể
              child: Stack(
                children: [
                  // Chân và giày
                  _buildLegs(),
                  
                  // Quần
                  _buildPants(),
                  
                  // Áo dài cách tân
                  _buildAodai(),
                  
                  // Thân người
                  _buildBody(),
                  
                  // Đầu và mặt
                  _buildHead(),
                  
                  // Tóc buộc 2 bên
                  _buildHair(),
                  
                  // Nón lá
                  _buildHat(),
                  
                  // Túi đeo chéo
                  _buildBag(),
                  
                  // Bản đồ Việt Nam
                  _buildMap(),
                  
                  // Tay vẫy chào
                  _buildWavingHand(),
                  
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

  Widget _buildLegs() {
    return Positioned(
      bottom: 0,
      left: widget.size * 0.35,
      right: widget.size * 0.35,
      child: Container(
        height: widget.size * 0.25,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E1), // Màu da
          borderRadius: BorderRadius.circular(widget.size * 0.1),
        ),
      ),
    );
  }

  Widget _buildPants() {
    return Positioned(
      bottom: widget.size * 0.25,
      left: widget.size * 0.25,
      right: widget.size * 0.25,
      child: Container(
        height: widget.size * 0.4,
        decoration: BoxDecoration(
          color: const Color(0xFF556B2F), // Xanh ô liu
          borderRadius: BorderRadius.circular(widget.size * 0.2),
        ),
      ),
    );
  }

  Widget _buildAodai() {
    return Positioned(
      top: widget.size * 0.35,
      left: widget.size * 0.1,
      right: widget.size * 0.1,
      bottom: widget.size * 0.25,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFB6C1), // Hồng nhạt
              const Color(0xFFFFC0CB), // Hồng nhạt hơn
            ],
          ),
          borderRadius: BorderRadius.circular(widget.size * 0.3),
          border: Border.all(
            color: const Color(0xFFFF69B4),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Họa tiết hoa sen lớn
            Positioned(
              bottom: widget.size * 0.1,
              right: widget.size * 0.05,
              child: _buildLotusPattern(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotusPattern() {
    return Container(
      width: widget.size * 0.25,
      height: widget.size * 0.25,
      decoration: BoxDecoration(
        color: const Color(0xFFFF1493).withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.local_florist,
        color: Color(0xFFFF1493),
        size: 20,
      ),
    );
  }

  Widget _buildBody() {
    return Positioned(
      top: widget.size * 0.3,
      left: widget.size * 0.25,
      right: widget.size * 0.25,
      bottom: widget.size * 0.25,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E1), // Màu da
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildHead() {
    return Positioned(
      top: widget.size * 0.1,
      left: widget.size * 0.2,
      right: widget.size * 0.2,
      child: Container(
        width: widget.size * 0.6,
        height: widget.size * 0.6,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E1), // Màu da
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFB6C1),
            width: 2,
          ),
        ),
        child: _buildFace(),
      ),
    );
  }

  Widget _buildFace() {
    return Stack(
      children: [
        // Mắt to long lanh
        Positioned(
          top: widget.size * 0.2,
          left: widget.size * 0.15,
          child: _buildEye(widget.size * 0.12),
        ),
        Positioned(
          top: widget.size * 0.2,
          right: widget.size * 0.15,
          child: _buildEye(widget.size * 0.12),
        ),

        // Lông mày
        Positioned(
          top: widget.size * 0.15,
          left: widget.size * 0.12,
          child: _buildEyebrow(),
        ),
        Positioned(
          top: widget.size * 0.15,
          right: widget.size * 0.12,
          child: _buildEyebrow(),
        ),

        // Mũi
        Positioned(
          top: widget.size * 0.35,
          left: 0.0,
          right: 0.0,
          child: _buildNose(),
        ),

        // Miệng cười tươi
        Positioned(
          bottom: widget.size * 0.25,
          left: 0.0,
          right: 0.0,
          child: _buildMouth(),
        ),

        // Má hồng
        Positioned(
          bottom: widget.size * 0.3,
          left: widget.size * 0.1,
          child: _buildCheek(),
        ),
        Positioned(
          bottom: widget.size * 0.3,
          right: widget.size * 0.1,
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
            color: const Color(0xFF4A4A4A),
          ),
          child: Center(
            child: Container(
              width: eyeSize * 0.6,
              height: eyeSize * 0.6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Container(
                  width: eyeSize * 0.3,
                  height: eyeSize * 0.3,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEyebrow() {
    return Container(
      width: widget.size * 0.08,
      height: widget.size * 0.02,
      decoration: BoxDecoration(
        color: const Color(0xFF8B4513),
        borderRadius: BorderRadius.circular(widget.size * 0.01),
      ),
    );
  }

  Widget _buildNose() {
    return Container(
      width: widget.size * 0.04,
      height: widget.size * 0.04,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E1),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFB6C1),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildMouth() {
    IconData mouthIcon;
    double mouthSize = widget.size * 0.15;

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
            color: const Color(0xFFFF69B4),
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
          width: widget.size * 0.06,
          height: widget.size * 0.06,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFB6C1).withOpacity(0.5 + _pulseController.value * 0.3),
          ),
        );
      },
    );
  }

  Widget _buildHair() {
    return Stack(
      children: [
        // Tóc buộc bên trái
        Positioned(
          top: widget.size * 0.25,
          left: widget.size * 0.05,
          child: Container(
            width: widget.size * 0.25,
            height: widget.size * 0.4,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(widget.size * 0.2),
            ),
          ),
        ),
        
        // Tóc buộc bên phải
        Positioned(
          top: widget.size * 0.25,
          right: widget.size * 0.05,
          child: Container(
            width: widget.size * 0.25,
            height: widget.size * 0.4,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(widget.size * 0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHat() {
    return Positioned(
      top: widget.size * 0.05,
      left: widget.size * 0.15,
      child: Transform.rotate(
        angle: _wiggleAnimation.value * 0.3,
        child: Container(
          width: widget.size * 0.7,
          height: widget.size * 0.3,
          decoration: BoxDecoration(
            color: const Color(0xFFDEB887), // Màu be
            borderRadius: BorderRadius.circular(widget.size * 0.4),
            border: Border.all(
              color: const Color(0xFF8B4513),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.5,
              height: widget.size * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFF654321),
                borderRadius: BorderRadius.circular(widget.size * 0.2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBag() {
    return Positioned(
      top: widget.size * 0.4,
      left: widget.size * 0.05,
      child: Transform.rotate(
        angle: _wiggleAnimation.value * 0.2,
        child: Container(
          width: widget.size * 0.2,
          height: widget.size * 0.25,
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.08,
              height: widget.size * 0.08,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Positioned(
      top: widget.size * 0.45,
      right: widget.size * 0.05,
      child: Container(
        width: widget.size * 0.25,
        height: widget.size * 0.2,
        decoration: BoxDecoration(
          color: const Color(0xFFDEB887),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFF8B4513),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.map,
          color: Color(0xFF556B2F),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildWavingHand() {
    return Positioned(
      top: widget.size * 0.35,
      left: widget.size * 0.05,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _waveAnimation.value * 0.5,
            child: Container(
              width: widget.size * 0.15,
              height: widget.size * 0.25,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E1),
                borderRadius: BorderRadius.circular(widget.size * 0.1),
              ),
            ),
          );
        },
      ),
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
                    size: 10,
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
}

// Container widget với animation
class AuthenticSenniContainer extends StatefulWidget {
  final String situation;
  final String? customMessage;
  final String? provinceName;
  final VoidCallback? onSenniTap;
  final bool showSenni;
  final double senniSize;
  final Duration messageDuration;
  final bool autoHide;

  const AuthenticSenniContainer({
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
  State<AuthenticSenniContainer> createState() => _AuthenticSenniContainerState();
}

class _AuthenticSenniContainerState extends State<AuthenticSenniContainer>
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
  void didUpdateWidget(AuthenticSenniContainer oldWidget) {
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
          AuthenticSenniWidget(
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
class AuthenticSenniHelper {
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
        AuthenticSenniContainer(
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