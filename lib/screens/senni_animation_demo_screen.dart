import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_senni_widget.dart';
import 'dart:math' as math;

class SenniAnimationDemoScreen extends StatefulWidget {
  const SenniAnimationDemoScreen({Key? key}) : super(key: key);

  @override
  State<SenniAnimationDemoScreen> createState() => _SenniAnimationDemoScreenState();
}

class _SenniAnimationDemoScreenState extends State<SenniAnimationDemoScreen> {
  String _currentSituation = 'greeting';
  String? _currentProvince;
  bool _isAnimating = false;

  final List<Map<String, dynamic>> _animationActions = [
    {
      'title': '🎭 Nhảy múa',
      'description': 'Senni nhảy lên xuống và lắc lư',
      'action': () => 'dance',
    },
    {
      'title': '🎉 Ăn mừng',
      'description': 'Senni phóng to và có sparkles',
      'action': () => 'celebrate',
    },
    {
      'title': '🤔 Suy nghĩ',
      'description': 'Senni lắc đầu và nhíu mày',
      'action': () => 'thinking',
    },
    {
      'title': '😊 Vui vẻ',
      'description': 'Senni cười tươi và nhảy nhót',
      'action': () => 'happy',
    },
    {
      'title': '🌟 Thành tích',
      'description': 'Senni ăn mừng thành tích',
      'action': () => 'achievement',
    },
    {
      'title': '🎯 Trả lời đúng',
      'description': 'Senni vui mừng khi đúng',
      'action': () => 'correct_answer',
    },
    {
      'title': '💪 Khuyến khích',
      'description': 'Senni động viên khi sai',
      'action': () => 'wrong_answer',
    },
    {
      'title': '🏆 Mở khóa tỉnh',
      'description': 'Senni ăn mừng mở khóa Hà Nội',
      'action': () => 'province_unlock',
      'province': 'Hà Nội',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedSenniHelper.showSenniInScreen(
      situation: _currentSituation,
      provinceName: _currentProvince,
      senniSize: 120,
      messageDuration: const Duration(seconds: 4),
      autoHide: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎭 Senni Animation Demo'),
          backgroundColor: AppTheme.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryOrange.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '🌸 Senni Animation Showcase',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Khám phá tất cả animation sinh động của Senni!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Animation controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isAnimating ? null : _triggerAnimation,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('🎭 Trigger Animation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _resetAnimation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('🔄 Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Animation list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _animationActions.length,
                  itemBuilder: (context, index) {
                    final action = _animationActions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.lightOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            _getIconForAction(action['action']()),
                            color: AppTheme.primaryOrange,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          action['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          action['description'],
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Icon(
                          Icons.play_circle_outline,
                          color: AppTheme.primaryOrange,
                          size: 28,
                        ),
                        onTap: () => _triggerSpecificAnimation(action),
                      ),
                    );
                  },
                ),
              ),

              // Info section
              Container(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Animation Features',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildFeatureItem('🔄 Bounce liên tục', 'Senni nhảy lên xuống nhẹ nhàng'),
                        _buildFeatureItem('🎭 Wiggle thỉnh thoảng', 'Lắc lư để thu hút sự chú ý'),
                        _buildFeatureItem('✨ Sparkles khi celebrate', 'Hiệu ứng sao lấp lánh'),
                        _buildFeatureItem('👁️ Blink animation', 'Mắt nhấp nháy tự nhiên'),
                        _buildFeatureItem('💫 Pulse effect', 'Phóng to thu nhỏ theo nhịp'),
                        _buildFeatureItem('🎨 Dynamic colors', 'Màu sắc thay đổi theo mood'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForAction(String action) {
    switch (action) {
      case 'dance':
        return Icons.music_note;
      case 'celebrate':
        return Icons.celebration;
      case 'thinking':
        return Icons.psychology;
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'achievement':
        return Icons.emoji_events;
      case 'correct_answer':
        return Icons.check_circle;
      case 'wrong_answer':
        return Icons.favorite;
      case 'province_unlock':
        return Icons.location_on;
      default:
        return Icons.star;
    }
  }

  void _triggerAnimation() {
    setState(() {
      _isAnimating = true;
    });

    // Trigger random animation
    final random = math.Random();
    final randomAction = _animationActions[random.nextInt(_animationActions.length)];
    _triggerSpecificAnimation(randomAction);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  void _triggerSpecificAnimation(Map<String, dynamic> action) {
    setState(() {
      _currentSituation = action['action']();
      _currentProvince = action['province'];
      _isAnimating = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  void _resetAnimation() {
    setState(() {
      _currentSituation = 'greeting';
      _currentProvince = null;
      _isAnimating = false;
    });
  }
} 