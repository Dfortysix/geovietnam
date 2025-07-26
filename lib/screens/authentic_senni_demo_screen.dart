import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/authentic_senni_widget.dart';

class AuthenticSenniDemoScreen extends StatefulWidget {
  const AuthenticSenniDemoScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticSenniDemoScreen> createState() => _AuthenticSenniDemoScreenState();
}

class _AuthenticSenniDemoScreenState extends State<AuthenticSenniDemoScreen> {
  String _currentSituation = 'greeting';
  String? _currentProvince;
  bool _isAnimating = false;

  final List<Map<String, dynamic>> _demoActions = [
    {
      'title': '🗺️ Chào mừng',
      'description': 'Senni chào hỏi người chơi',
      'situation': 'greeting',
      'province': null,
    },
    {
      'title': '🎯 Trả lời đúng',
      'description': 'Senni vui mừng khi đúng',
      'situation': 'correct_answer',
      'province': null,
    },
    {
      'title': '💪 Khuyến khích',
      'description': 'Senni động viên khi sai',
      'situation': 'wrong_answer',
      'province': null,
    },
    {
      'title': '🏆 Mở khóa Hà Nội',
      'description': 'Senni ăn mừng mở khóa tỉnh',
      'situation': 'province_unlock',
      'province': 'Hà Nội',
    },
    {
      'title': '🌟 Thành tích',
      'description': 'Senni ăn mừng thành tích',
      'situation': 'achievement',
      'province': null,
    },
    {
      'title': '🌸 Kết thúc game',
      'description': 'Senni cảm ơn người chơi',
      'situation': 'game_end',
      'province': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AuthenticSenniHelper.showSenniInScreen(
      situation: _currentSituation,
      provinceName: _currentProvince,
      senniSize: 120,
      messageDuration: const Duration(seconds: 5),
      autoHide: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🌸 Senni Authentic Demo'),
          backgroundColor: AppTheme.primaryOrange,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFB6C1).withOpacity(0.1),
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
                      '🌸 Bé Sen "Senni" Authentic',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Linh vật theo đúng phong cách mascot.txt',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Senni info card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Thông tin Senni',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem('👧 Tuổi', '7-9 tuổi'),
                        _buildInfoItem('👗 Trang phục', 'Áo dài cách tân hồng nhạt'),
                        _buildInfoItem('🌸 Họa tiết', 'Hoa sen'),
                        _buildInfoItem('👒 Nón', 'Nón lá nhỏ'),
                        _buildInfoItem('💇‍♀️ Tóc', 'Buộc 2 bên'),
                        _buildInfoItem('👜 Túi', 'Túi bản đồ'),
                        _buildInfoItem('👀 Mắt', 'To long lanh'),
                        _buildInfoItem('😊 Miệng', 'Cười tươi'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Demo actions
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _demoActions.length,
                  itemBuilder: (context, index) {
                    final action = _demoActions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB6C1).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            _getIconForSituation(action['situation']),
                            color: const Color(0xFFFF69B4),
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
                          color: const Color(0xFFFF69B4),
                          size: 28,
                        ),
                        onTap: () => _triggerAction(action),
                      ),
                    );
                  },
                ),
              ),

              // Footer
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
                              Icons.psychology,
                              color: const Color(0xFFFF69B4),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tính cách Senni',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPersonalityItem('⚡ Năng động', 'Luôn hứng khởi, nhảy nhót'),
                        _buildPersonalityItem('🧠 Thông minh', 'Gợi ý thú vị về vùng miền'),
                        _buildPersonalityItem('🤝 Thân thiện', 'Gọi người chơi là "bạn đồng hành"'),
                        _buildPersonalityItem('🌿 Yêu thiên nhiên', 'Nhắc tới hoa sen, di tích'),
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

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityItem(String trait, String description) {
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
                  trait,
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

  IconData _getIconForSituation(String situation) {
    switch (situation) {
      case 'greeting':
        return Icons.waving_hand;
      case 'correct_answer':
        return Icons.check_circle;
      case 'wrong_answer':
        return Icons.favorite;
      case 'province_unlock':
        return Icons.location_on;
      case 'achievement':
        return Icons.emoji_events;
      case 'game_end':
        return Icons.celebration;
      default:
        return Icons.star;
    }
  }

  void _triggerAction(Map<String, dynamic> action) {
    setState(() {
      _currentSituation = action['situation'];
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
} 