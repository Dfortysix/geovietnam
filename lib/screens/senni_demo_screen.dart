import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/image_senni_widget.dart';
import '../services/senni_service.dart';

class SenniDemoScreen extends StatefulWidget {
  const SenniDemoScreen({Key? key}) : super(key: key);

  @override
  State<SenniDemoScreen> createState() => _SenniDemoScreenState();
}

class _SenniDemoScreenState extends State<SenniDemoScreen> {
  String _currentSituation = 'greeting';
  String? _currentProvince;
  final SenniService _senniService = SenniService();

  final List<Map<String, dynamic>> _demoActions = [
    {
      'title': 'Chào mừng',
      'situation': 'greeting',
      'description': 'Senni chào mừng người chơi',
      'color': Colors.blue,
    },
    {
      'title': 'Trả lời đúng',
      'situation': 'correct_answer',
      'description': 'Senni chúc mừng khi trả lời đúng',
      'color': Colors.green,
    },
    {
      'title': 'Trả lời sai',
      'situation': 'wrong_answer',
      'description': 'Senni động viên khi trả lời sai',
      'color': Colors.orange,
    },
    {
      'title': 'Mở khóa Hà Nội',
      'situation': 'province_unlock',
      'province': 'Ha Noi',
      'description': 'Senni chúc mừng mở khóa tỉnh mới',
      'color': Colors.purple,
    },
    {
      'title': 'Mở khóa Huế',
      'situation': 'province_unlock',
      'province': 'Hue',
      'description': 'Senni chúc mừng mở khóa tỉnh mới',
      'color': Colors.purple,
    },
    {
      'title': 'Thông tin Hà Nội',
      'situation': 'province_info',
      'province': 'Ha Noi',
      'description': 'Senni giới thiệu về tỉnh',
      'color': Colors.teal,
    },
    {
      'title': 'Thành tích',
      'situation': 'achievement',
      'description': 'Senni chúc mừng đạt thành tích',
      'color': Colors.amber,
    },
    {
      'title': 'Kết thúc game',
      'situation': 'game_end',
      'description': 'Senni tạm biệt người chơi',
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ImageSenniHelper.showSenniInScreen(
      situation: _currentSituation,
      provinceName: _currentProvince,
      senniSize: 120,
      messageDuration: const Duration(seconds: 5),
      autoHide: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🌸 Demo Senni Mascot'),
          backgroundColor: AppTheme.primaryOrange,
          foregroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '🎀 Bé Sen "Senni"',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Linh vật khám phá đất Việt',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Current situation display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      'Tình huống hiện tại:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getSituationDisplayName(_currentSituation),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_currentProvince != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tỉnh: $_currentProvince',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _demoActions.length,
                    itemBuilder: (context, index) {
                      final action = _demoActions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          onPressed: () => _triggerAction(action),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: action['color'],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                action['title'],
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                action['description'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerAction(Map<String, dynamic> action) {
    setState(() {
      _currentSituation = action['situation'];
      _currentProvince = action['province'];
    });
  }

  String _getSituationDisplayName(String situation) {
    switch (situation) {
      case 'greeting':
        return 'Chào mừng';
      case 'correct_answer':
        return 'Trả lời đúng';
      case 'wrong_answer':
        return 'Trả lời sai';
      case 'province_unlock':
        return 'Mở khóa tỉnh';
      case 'province_info':
        return 'Thông tin tỉnh';
      case 'achievement':
        return 'Thành tích';
      case 'game_end':
        return 'Kết thúc game';
      default:
        return 'Không xác định';
    }
  }
} 