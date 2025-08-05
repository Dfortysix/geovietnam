import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/daily_challenge_service.dart';
import '../services/game_progress_service.dart';
import '../models/province.dart';
import 'map_exploration_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({Key? key}) : super(key: key);

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  Map<String, dynamic>? _dailyChallenge;
  Province? _selectedProvince;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestion = 0;
  int _score = 0;
  bool _isGameCompleted = false;
  bool _isLoading = true;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  bool _showUnlockAnimation = false;
  String? _unlockedProvinceName;

  @override
  void initState() {
    super.initState();
    _loadDailyChallenge();
  }

  Future<void> _loadDailyChallenge() async {
    try {
      final challenge = await DailyChallengeService.getCurrentDailyChallenge();
      final province = challenge['selectedProvince'] as Province;
      
      // Load câu hỏi cho tỉnh được chọn
      final questions = await DailyChallengeService.loadQuestionsForProvince(province.id);
      
      // Shuffle câu hỏi để tạo sự đa dạng và chỉ lấy 7 câu đầu tiên
      questions.shuffle();
      final selectedQuestions = questions.take(7).toList();
      
              setState(() {
          _dailyChallenge = challenge;
          _selectedProvince = province;
          _questions = selectedQuestions;
          _isLoading = false;
        });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Không thể tải daily challenge. Vui lòng thử lại.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryOrange,
            ),
          ),
        ),
      );
    }

    if (_isGameCompleted) {
      return _buildGameCompletedScreen();
    }

    if (_currentQuestion >= _questions.length) {
      _completeGame();
      return _buildGameCompletedScreen();
    }

    final currentQ = _questions[_currentQuestion];

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
                  'Điểm: $_score',
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
        child: SafeArea(
          child: Column(
            children: [
              // Header với thông tin tỉnh và tiến độ
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Thông tin tỉnh được chọn
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.glowShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tỉnh hôm nay:',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _selectedProvince?.nameVietnamese ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Thông tin số lần thử
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Câu hỏi ${_currentQuestion + 1}/${_questions.length}',
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Lần thử: ${_dailyChallenge?['attempts'] ?? 0}/${_dailyChallenge?['maxAttempts'] ?? 3}',
                            style: const TextStyle(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Câu hỏi
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQ['question'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Các lựa chọn
                      ...List.generate(
                        (currentQ['options'] as List).length,
                        (index) => _buildOptionButton(
                          currentQ['options'][index],
                          index,
                          currentQ['answer'] == index,
                        ),
                      ),
                    ],
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

  Widget _buildOptionButton(String option, int index, bool isCorrect) {
    final isSelected = _selectedAnswer == option;
    Color backgroundColor = Colors.grey.shade100;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black87;

    if (_showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade700;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade700;
      }
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryOrange.withValues(alpha: 0.1);
      borderColor = AppTheme.primaryOrange;
      textColor = AppTheme.primaryOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showResult ? null : () => _checkAnswer(option, isCorrect),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (_showResult && isCorrect)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                if (_showResult && isSelected && !isCorrect)
                  const Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkAnswer(String selectedAnswer, bool isCorrect) {
    setState(() {
      _selectedAnswer = selectedAnswer;
      _showResult = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _score += 10;
    }

    // Chuyển sang câu hỏi tiếp theo sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentQuestion++;
          _selectedAnswer = null;
          _showResult = false;
        });
      }
    });
  }

  void _completeGame() async {
    setState(() {
      _isGameCompleted = true;
    });

    // Tăng số lần thử
    await DailyChallengeService.incrementAttempts();
    
    // Lưu tiến độ game
    await GameProgressService.updateScore(_score);
    await GameProgressService.updateDailyStreak();

    // Kiểm tra xem có mở khóa được tỉnh mới không (70 điểm = 7 câu đúng)
    if (_score >= 70) {
      // Unlock chính tỉnh đang chơi trong daily challenge
      if (_selectedProvince != null) {
        await GameProgressService.unlockProvince(_selectedProvince!.id);
        await DailyChallengeService.markProvinceUnlockedToday(); // Đánh dấu đã unlock hôm nay
        setState(() {
          _unlockedProvinceName = _selectedProvince!.nameVietnamese;
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
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
                          _score >= 70 ? Icons.celebration : Icons.sentiment_dissatisfied,
                          size: 64,
                          color: _score >= 70 ? AppTheme.primaryOrange : Colors.grey,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _score >= 70 ? 'Chúc mừng!' : 'Cố gắng hơn!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bạn đã hoàn thành Daily Challenge với $_score điểm',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Thông tin tỉnh được chọn
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppTheme.primaryOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tỉnh: ${_selectedProvince?.nameVietnamese ?? ''}',
                                style: const TextStyle(
                                  color: AppTheme.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Hiển thị unlock animation nếu đạt đủ điểm
                        if (_showUnlockAnimation && _unlockedProvinceName != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.glowShadow,
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.lock_open,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Mở khóa thành công!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tỉnh $_unlockedProvinceName đã được mở khóa',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Nút chơi lại
                        if (_dailyChallenge?['canPlay'] == true)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Chơi lại',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Nút xem bản đồ
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapExplorationScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryOrange,
                              side: const BorderSide(color: AppTheme.primaryOrange),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Xem bản đồ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Nút về trang chủ
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textSecondary,
                              side: BorderSide(color: AppTheme.textSecondary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Về trang chủ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 