import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/vietnam_map_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String? selectedProvince;
  int score = 0;
  int currentQuestion = 0;
  
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
    return Scaffold(
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
                      '🎯 ${((score / (questions.length * 10)) * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Câu hỏi hiện tại
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  Text(
                    questions[currentQuestion]['question'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Các lựa chọn
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: questions[currentQuestion]['options']
                        .map<Widget>((option) => _buildOptionButton(option))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bản đồ Việt Nam
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: VietnamMapWidget(
                    onProvinceTap: _handleProvinceTap,
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: currentQuestion > 0 ? _previousQuestion : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Trước'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  
                  ElevatedButton.icon(
                    onPressed: currentQuestion < questions.length - 1 ? _nextQuestion : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Tiếp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  
                  ElevatedButton.icon(
                    onPressed: _finishGame,
                    icon: const Icon(Icons.flag),
                    label: const Text('Kết thúc'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chính xác! +10 điểm'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
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
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestion > 0) {
      setState(() {
        currentQuestion--;
        selectedProvince = null;
      });
    }
  }

  void _finishGame() {
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
    });
  }
} 