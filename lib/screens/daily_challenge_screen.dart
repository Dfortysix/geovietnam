import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/daily_challenge_service.dart';
import '../services/game_progress_service.dart';
import '../models/province.dart';
import 'map_exploration_screen.dart';
import 'settings_screen.dart';
import '../services/haptic_service.dart';

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
  int _correctCount = 0;
  bool _isGameCompleted = false;
  bool _isLoading = true;
  String? _selectedAnswer;
  bool _showResult = false;
  
  bool _showUnlockAnimation = false;
  String? _unlockedProvinceName;
  
  // Timer cho câu hỏi
  Timer? _questionTimer;
  int _timeRemaining = 15; // 15 giây cho mỗi câu hỏi

  @override
  void initState() {
    super.initState();
    _loadDailyChallenge();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDailyChallenge() async {
    try {
      print('🚀 Bắt đầu load daily challenge...');
      
      // Debug SharedPreferences trước
      await DailyChallengeService.debugSharedPreferences();
      
      final challenge = await DailyChallengeService.getCurrentDailyChallenge();
      final province = challenge['selectedProvince'] as Province;
      print('📍 Tỉnh được chọn: ${province.nameVietnamese}');
      
      // Kiểm tra xem có trạng thái chơi đã lưu không
      final hasSavedState = await DailyChallengeService.hasSavedGameState();
      
      if (hasSavedState) {
        print('🔄 Khôi phục trạng thái chơi đã lưu...');
        // Khôi phục trạng thái chơi đã lưu
        final savedState = await DailyChallengeService.getSavedGameState();
                 setState(() {
           _dailyChallenge = challenge;
           _selectedProvince = province;
           _questions = List<Map<String, dynamic>>.from(savedState['questions']);
           _currentQuestion = savedState['currentQuestion'];
           _score = savedState['score'];
           _correctCount = savedState['correctCount'] ?? 0;
           _isLoading = false;
         });
         print('✅ Đã khôi phục: câu $_currentQuestion, điểm $_score');
         
         // Khi khôi phục trạng thái, luôn reset về trạng thái chưa trả lời
         setState(() {
           _selectedAnswer = null;
           _showResult = false;
           
         });
         
         // Bắt đầu timer với 15 giây mới
         _startQuestionTimer();
      } else {
        print('🆕 Tạo game mới...');
        // Load câu hỏi mới cho tỉnh được chọn
        final questions = await DailyChallengeService.loadQuestionsForProvince(province.id);
        
        // Shuffle câu hỏi để tạo sự đa dạng và chỉ lấy 7 câu đầu tiên
        questions.shuffle();
        final selectedQuestions = questions.take(7).toList();
        
                 setState(() {
           _dailyChallenge = challenge;
           _selectedProvince = province;
           _questions = selectedQuestions;
           _currentQuestion = 0;
           _score = 0;
           _correctCount = 0;
           _selectedAnswer = null;
           _showResult = false;
           _isLoading = false;
         });
         
         // Bắt đầu timer cho câu hỏi đầu tiên
         _startQuestionTimer();
         
         // Lưu trạng thái ban đầu
         await DailyChallengeService.saveGameState(
           currentQuestion: _currentQuestion,
           score: _score,
           questions: _questions,
           correctCount: _correctCount,
         );
         print('💾 Đã lưu trạng thái ban đầu');
      }
    } catch (e) {
      print('❌ Lỗi khi load daily challenge: $e');
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

  // Bắt đầu timer cho câu hỏi hiện tại
  void _startQuestionTimer() {
    // Luôn reset thời gian về 15 giây
    _timeRemaining = 15;
    print('🔄 Bắt đầu timer với 15 giây cho câu $_currentQuestion');
    _startTimer();
  }



  // Phương thức chung để bắt đầu timer
  void _startTimer() {
    _questionTimer?.cancel();
    print('⏱️ Bắt đầu timer với $_timeRemaining giây');
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeRemaining--;
        });
        
        if (_timeRemaining <= 0) {
          timer.cancel();
          print('⏰ Timer kết thúc!');
          _onTimeUp();
        }
      }
    });
  }

  // Dừng timer
  void _stopQuestionTimer() {
    _questionTimer?.cancel();
  }

  // Xử lý khi hết thời gian
  void _onTimeUp() {
    if (!_showResult) {
      print('⏰ Hết thời gian! Tự động chọn câu trả lời sai');
      HapticService().medium();
      
      // Tìm một đáp án sai để chọn
      final currentQ = _questions[_currentQuestion];
      final correctAnswerIndex = currentQ['answer'] as int;
      final options = currentQ['options'] as List;
      
      // Tìm đáp án sai đầu tiên (không phải đáp án đúng)
      String wrongAnswer = '';
      for (int i = 0; i < options.length; i++) {
        if (i != correctAnswerIndex) {
          wrongAnswer = options[i];
          break;
        }
      }
      
      // Tự động chọn đáp án sai
      _checkAnswer(wrongAnswer, false);
    }
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('🎯 Daily Challenge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.settings, color: AppTheme.primaryOrange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              tooltip: 'Cài đặt',
            ),
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // Thông tin tỉnh được chọn
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.glowShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tỉnh hôm nay:',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  _selectedProvince?.nameVietnamese ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                                         // Thông tin số lần thử và timer
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           'Câu hỏi ${_currentQuestion + 1}/${_questions.length}',
                           style: const TextStyle(
                             color: AppTheme.primaryOrange,
                             fontWeight: FontWeight.bold,
                             fontSize: 14,
                           ),
                         ),
                         Row(
                           children: [
                             // Timer
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(
                                 color: _timeRemaining <= 5 
                                   ? Colors.red.withValues(alpha: 0.1)
                                   : AppTheme.primaryOrange.withValues(alpha: 0.1),
                                 borderRadius: BorderRadius.circular(16),
                                 border: Border.all(
                                   color: _timeRemaining <= 5 
                                     ? Colors.red.withValues(alpha: 0.3)
                                     : AppTheme.primaryOrange.withValues(alpha: 0.3)
                                 ),
                               ),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Icon(
                                     Icons.timer,
                                     size: 14,
                                     color: _timeRemaining <= 5 
                                       ? Colors.red 
                                       : AppTheme.primaryOrange,
                                   ),
                                   const SizedBox(width: 4),
                                   Text(
                                     '$_timeRemaining',
                                     style: TextStyle(
                                       color: _timeRemaining <= 5 
                                         ? Colors.red 
                                         : AppTheme.primaryOrange,
                                       fontWeight: FontWeight.bold,
                                       fontSize: 12,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             const SizedBox(width: 8),
                             // Số lần thử
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(
                                 color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                                 borderRadius: BorderRadius.circular(16),
                                 border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
                               ),
                               child: Text(
                                 'Lần thử: ${_dailyChallenge?['attempts'] ?? 0}/${_dailyChallenge?['maxAttempts'] ?? 3}',
                                 style: const TextStyle(
                                   color: AppTheme.primaryOrange,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 12,
                                 ),
                               ),
                             ),
                           ],
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
                  child: SingleChildScrollView(
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
                        
                        // Thêm padding bottom để tránh bị che bởi keyboard
                        const SizedBox(height: 20),
                      ],
                    ),
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

  void _checkAnswer(String selectedAnswer, bool isCorrect) async {
    // Dừng timer hiện tại
    _stopQuestionTimer();
    
    setState(() {
      _selectedAnswer = selectedAnswer;
      _showResult = true;
    });

    if (isCorrect) {
      final int gained = 10 * _timeRemaining;
      _score += gained;
      _correctCount += 1;
      print('✅ Trả lời đúng! +$gained điểm (thời gian còn lại: $_timeRemaining s)');
      HapticService().light();
    } else {
      print('❌ Trả lời sai!');
      HapticService().medium();
    }

    // Lưu trạng thái hiện tại (không lưu trạng thái tạm thời)
    await DailyChallengeService.saveGameState(
      currentQuestion: _currentQuestion,
      score: _score,
      questions: _questions,
      correctCount: _correctCount,
    );

    // Chuyển sang câu hỏi tiếp theo sau 2 giây
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        setState(() {
          _currentQuestion++;
          _selectedAnswer = null;
          _showResult = false;
          // Reset thời gian về 15 giây cho câu hỏi mới
          _timeRemaining = 15;
        });
        
        // Lưu trạng thái sau khi chuyển câu hỏi
        await DailyChallengeService.saveGameState(
          currentQuestion: _currentQuestion,
          score: _score,
          questions: _questions,
          correctCount: _correctCount,
        );
        
        // Bắt đầu timer cho câu hỏi mới
        _startQuestionTimer();
      }
    });
  }

  void _completeGame() async {
    // Dừng timer
    _stopQuestionTimer();
    
    setState(() {
      _isGameCompleted = true;
    });

    // Xóa trạng thái chơi đã lưu
    await DailyChallengeService.clearSavedGameState();

    // Tăng số lần thử
    await DailyChallengeService.incrementAttempts();
    
    // Kiểm tra xem có mở khóa được tỉnh mới không (ví dụ: đủ điểm)
    if (_correctCount >= 6) {
      // Unlock chính tỉnh đang chơi trong daily challenge
      if (_selectedProvince != null) {
        final didUnlock = await GameProgressService.unlockProvince(_selectedProvince!.id);
        if (didUnlock) {
          HapticService().heavy();
          await DailyChallengeService.markProvinceUnlockedToday(); // Đánh dấu đã unlock hôm nay
          // Chỉ khi đã mở khóa hôm nay mới cập nhật tổng điểm và streak
          await GameProgressService.updateScore(_score);
          await GameProgressService.updateDailyStreak();
        }
        
        setState(() {
          _unlockedProvinceName = _selectedProvince!.nameVietnamese;
          _showUnlockAnimation = true;
        });
      }
    }
  }

  Widget _buildGameCompletedScreen() {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                          _correctCount >= 6 ? Icons.celebration : Icons.sentiment_dissatisfied,
                          size: 64,
                          color: _correctCount >= 6 ? AppTheme.primaryOrange : Colors.grey,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _correctCount >= 6 ? 'Chúc mừng!' : 'Cố gắng hơn!',
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