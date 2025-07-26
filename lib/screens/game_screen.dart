import 'package:flutter/material.dart';
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
        title: Text('Game Địa Lý Việt Nam'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header với thông tin game
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Câu hỏi ${currentQuestion + 1}/${questions.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Điểm: $score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Level 1',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Câu hỏi hiện tại
            if (currentQuestion < questions.length)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Câu hỏi:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      questions[currentQuestion]['question'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: 16),
            
            // Bản đồ Việt Nam
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: VietnamMapWidget(
                  onProvinceTap: _handleProvinceTap,
                  interactive: true,
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Các lựa chọn
            if (currentQuestion < questions.length)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'Chọn tỉnh trên bản đồ hoặc chọn từ danh sách:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 12),
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
            
            SizedBox(height: 16),
            
            // Nút điều khiển
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentQuestion > 0 ? _previousQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.grey.shade700,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Câu trước'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: currentQuestion < questions.length - 1 
                          ? _nextQuestion 
                          : _finishGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildOptionButton(String option) {
    bool isSelected = selectedProvince == option;
    bool isCorrect = option == questions[currentQuestion]['answer'];
    
    return GestureDetector(
      onTap: () => _selectOption(option),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isCorrect ? Colors.green.shade100 : Colors.red.shade100)
              : Colors.white,
          border: Border.all(
            color: isSelected 
                ? (isCorrect ? Colors.green.shade400 : Colors.red.shade400)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected 
                ? (isCorrect ? Colors.green.shade700 : Colors.red.shade700)
                : Colors.black87,
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
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sai rồi! Đáp án đúng là: $correctAnswer'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
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
        title: Text('Kết thúc game'),
        content: Text('Điểm số của bạn: $score/${questions.length * 10}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: Text('Chơi lại'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Về menu'),
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