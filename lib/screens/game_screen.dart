import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/vietnam_map_widget.dart';
import '../widgets/image_senni_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? selectedProvince;
  int score = 0;
  int currentQuestion = 0;
  String _senniSituation = 'greeting';
  String? _senniProvinceName;
  
  // Danh sách câu hỏi mẫu
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
      'question': 'Tỉnh nào có đảo Phú Quốc?',
      'answer': 'Kien Giang',
      'options': ['Kien Giang', 'Ca Mau', 'Bac Lieu', 'Soc Trang']
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ImageSenniHelper.showSenniInScreen(
      situation: _senniSituation,
      provinceName: _senniProvinceName,
      senniSize: 100,
      messageDuration: const Duration(seconds: 4),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            '🌏 GeoVietnam',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Column(
            children: [
              // Header với thông tin game
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Câu hỏi ${currentQuestion + 1}/${questions.length}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Điểm: $score',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Text(
                        'Level 1',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Câu hỏi hiện tại
              if (currentQuestion < questions.length)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu hỏi:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        questions[currentQuestion]['question'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Bản đồ Việt Nam
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: VietnamMapWidget(
                    onProvinceTap: _handleProvinceTap,
                    interactive: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Các lựa chọn
              if (currentQuestion < questions.length)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        'Chọn tỉnh trên bản đồ hoặc chọn từ danh sách:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: questions[currentQuestion]['options']
                            .map<Widget>((option) => _buildOptionButton(option))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Nút điều khiển
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentQuestion > 0 ? _previousQuestion : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonSecondary,
                          foregroundColor: AppTheme.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Câu trước'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentQuestion < questions.length - 1 
                            ? _nextQuestion 
                            : _finishGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: AppTheme.primaryOrange.withOpacity(0.3),
                          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          currentQuestion < questions.length - 1 
                              ? 'Câu tiếp' 
                              : 'Kết thúc',
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
    );
  }

  Widget _buildOptionButton(String option) {
    bool isSelected = selectedProvince == option;
    bool isCorrect = option == questions[currentQuestion]['answer'];
    Color bgColor = Colors.white;
    Color borderColor = AppTheme.lightOrange;
    Color textColor = AppTheme.textPrimary;
    if (isSelected) {
      if (isCorrect) {
        bgColor = AppTheme.buttonSuccess.withOpacity(0.15);
        borderColor = AppTheme.buttonSuccess;
        textColor = AppTheme.buttonSuccess;
      } else {
        bgColor = AppTheme.buttonError.withOpacity(0.15);
        borderColor = AppTheme.buttonError;
        textColor = AppTheme.buttonError;
      }
    }
    return GestureDetector(
      onTap: () => _selectOption(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? AppTheme.softShadow : [],
        ),
        child: Text(
          option,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }

  void _handleProvinceTap(String provinceName) {
    setState(() {
      selectedProvince = provinceName;
    });
    
    // Kiểm tra đáp án
    _checkAnswer(provinceName);
  }

  void _selectOption(String option) {
    setState(() {
      selectedProvince = option;
    });
    
    // Kiểm tra đáp án
    _checkAnswer(option);
  }

  void _checkAnswer(String selectedAnswer) {
    String correctAnswer = questions[currentQuestion]['answer'];
    bool isCorrect = selectedAnswer == correctAnswer;
    
    if (isCorrect) {
      score += 10;
      setState(() {
        _senniSituation = 'correct_answer';
        _senniProvinceName = selectedAnswer;
      });
      
      // Reset Senni situation after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _senniSituation = 'greeting';
            _senniProvinceName = null;
          });
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chính xác! +10 điểm'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _senniSituation = 'wrong_answer';
      });
      
      // Reset Senni situation after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _senniSituation = 'greeting';
          });
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sai rồi! Đáp án đúng là: $correctAnswer'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedProvince = null;
        _senniSituation = 'greeting';
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
        selectedProvince = null;
        _senniSituation = 'greeting';
      });
    }
  }

  void _finishGame() {
    setState(() {
      _senniSituation = 'game_end';
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết thúc game'),
        content: Text('Điểm số của bạn: $score/${questions.length * 10}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Chơi lại'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Về menu'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedProvince = null;
      _senniSituation = 'greeting';
      _senniProvinceName = null;
    });
  }
} 