import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/game_progress_service.dart';
import '../widgets/google_play_games_widget.dart';
import 'settings_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? selectedProvince;
  int score = 0;
  int currentQuestion = 0;
  bool _isGameCompleted = false;
  bool _showUnlockAnimation = false;
  String? _unlockedProvinceName;
  
  // Danh sách câu hỏi mẫu cho Daily Challenge
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Thủ đô của Việt Nam là gì?',
      'answer': 'Ha Noi',
      'options': ['Ha Noi', 'Ho Chi Minh', 'Da Nang', 'Hai Phong']
    },
    {
      'question': 'Tỉnh nào có diện tích lớn nhất Việt Nam?',
      'answer': 'Nghe An',
      'options': ['Nghe An', 'Gia Lai', 'Son La', 'Lam Dong']
    },
    {
      'question': 'Tỉnh nào có Vịnh Hạ Long?',
      'answer': 'Quang Ninh',
      'options': ['Quang Ninh', 'Hai Phong', 'Ha Noi', 'Bac Ninh']
    },
    {
      'question': 'Thành phố nào được gọi là "Thành phố Hoa Phượng Đỏ"?',
      'answer': 'Hai Phong',
      'options': ['Hai Phong', 'Ha Noi', 'Da Nang', 'Can Tho']
    },
    {
      'question': 'Tỉnh nào có thác Bản Giốc?',
      'answer': 'Cao Bang',
      'options': ['Cao Bang', 'Lang Son', 'Ha Giang', 'Tuyen Quang']
    },
    {
      'question': 'Thành phố nào được gọi là "Tây Đô"?',
      'answer': 'Can Tho',
      'options': ['Can Tho', 'An Giang', 'Kien Giang', 'Bac Lieu']
    },
    {
      'question': 'Tỉnh nào có Đà Lạt?',
      'answer': 'Lam Dong',
      'options': ['Lam Dong', 'Dak Lak', 'Gia Lai', 'Khanh Hoa']
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (_isGameCompleted) {
      return _buildGameCompletedScreen();
    }

    if (currentQuestion >= questions.length) {
      _completeGame();
      return _buildGameCompletedScreen();
    }

    final currentQ = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Daily Challenge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: AppTheme.primaryOrange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Điểm: $score',
                  style: const TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Progress indicator
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Câu hỏi ${currentQuestion + 1}/${questions.length}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Điểm: $score',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentQuestion + 1) / questions.length,
                    backgroundColor: AppTheme.lightOrange.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Question card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.quiz,
                            size: 48,
                            color: AppTheme.primaryOrange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentQ['question'],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Answer options
                    ...currentQ['options'].map<Widget>((option) => 
                      _buildAnswerOption(option, currentQ['answer'])
                    ).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(String option, String correctAnswer) {
    bool isSelected = selectedProvince == option;
    bool isCorrect = option == correctAnswer;
    bool showResult = selectedProvince != null;

    Color backgroundColor = Colors.white.withOpacity(0.9);
    Color borderColor = AppTheme.lightOrange.withOpacity(0.3);
    Color textColor = AppTheme.textPrimary;

    if (showResult) {
      if (isSelected) {
        if (isCorrect) {
          backgroundColor = Colors.green.withOpacity(0.1);
          borderColor = Colors.green;
          textColor = Colors.green;
        } else {
          backgroundColor = Colors.red.withOpacity(0.1);
          borderColor = Colors.red;
          textColor = Colors.red;
        }
      } else if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: selectedProvince == null ? () => _checkAnswer(option) : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryOrange : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isSelected 
                      ? (isCorrect ? Icons.check : Icons.close)
                      : Icons.circle_outlined,
                  color: isSelected ? Colors.white : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer(String selectedAnswer) {
    setState(() {
      selectedProvince = selectedAnswer;
    });

    final currentQ = questions[currentQuestion];
    if (selectedAnswer == currentQ['answer']) {
      score += 10;
    }

    // Chuyển sang câu hỏi tiếp theo sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          currentQuestion++;
          selectedProvince = null;
        });
      }
    });
  }

  void _completeGame() async {
    setState(() {
      _isGameCompleted = true;
    });

    // Lưu tiến độ game
    await GameProgressService.completeDailyChallenge(score);

    // Kiểm tra xem có mở khóa được tỉnh mới không
    if (score >= 70) {
      final nextProvince = await GameProgressService.getNextUnlockableProvince();
      if (nextProvince != null) {
        setState(() {
          _unlockedProvinceName = nextProvince.nameVietnamese;
          _showUnlockAnimation = true;
        });
      }
    }
  }

  Widget _buildGameCompletedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Daily Challenge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primaryOrange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Cài đặt',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Kết quả
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        score >= 70 ? Icons.celebration : Icons.sentiment_dissatisfied,
                        size: 64,
                        color: score >= 70 ? AppTheme.primaryOrange : Colors.grey,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        score >= 70 ? 'Chúc mừng!' : 'Cố gắng hơn!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bạn đã hoàn thành Daily Challenge',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryOrange.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Điểm số: $score/${questions.length * 10}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Đúng: ${(score / 10).round()}/${questions.length} câu',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Thông báo mở khóa
                if (_showUnlockAnimation && _unlockedProvinceName != null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.lock_open,
                          size: 48,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '🎉 Mở khóa thành công!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bạn đã mở khóa tỉnh: $_unlockedProvinceName',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().scale(duration: 600.ms).then().shimmer(duration: 1.seconds),

                const SizedBox(height: 32),

                // Google Play Games Integration
                GooglePlayGamesQuickActions(
                  currentScore: score,
                  gameMode: 'daily_challenge',
                ),

                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Về trang chủ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentQuestion = 0;
                            score = 0;
                            selectedProvince = null;
                            _isGameCompleted = false;
                            _showUnlockAnimation = false;
                            _unlockedProvinceName = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppTheme.primaryOrange),
                          ),
                        ),
                        child: Text(
                          'Chơi lại',
                          style: TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 