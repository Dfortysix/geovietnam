import 'package:flutter/material.dart';
import 'dart:math' as math;

class SenniPreviewWidget extends StatefulWidget {
  final double size;
  final String mood;
  final bool showAnimation;

  const SenniPreviewWidget({
    Key? key,
    this.size = 150,
    this.mood = 'happy',
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<SenniPreviewWidget> createState() => _SenniPreviewWidgetState();
}

class _SenniPreviewWidgetState extends State<SenniPreviewWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _waveController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
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

    if (widget.showAnimation) {
      _bounceController.repeat(reverse: true);
      _waveController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size * 1.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceController, _waveController]),
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(0.0, -_bounceAnimation.value * 8.0),
            child: Stack(
              children: [
                // Chân và giày
                // _buildLegs(),
                
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
              ],
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
          color: const Color(0xFFFFE4E1),
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
          color: const Color(0xFF556B2F),
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
              const Color(0xFFFFB6C1),
              const Color(0xFFFFC0CB),
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
              child: Container(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Positioned(
      top: widget.size * 0.25,
      left: widget.size * 0.15,
      right: widget.size * 0.15,
      bottom: widget.size * 0.2,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E1),
          borderRadius: BorderRadius.circular(widget.size * 0.4),
        ),
      ),
    );
  }

  Widget _buildHead() {
    return Positioned(
      top: widget.size * 0.05,
      left: widget.size * 0.15,
      right: widget.size * 0.15,
      child: Container(
        width: widget.size * 0.7,
        height: widget.size * 0.7,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4E1),
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
        // Mắt to long lanh - nhỏ hơn như trong hình
        Positioned(
          top: widget.size * 0.25,
          left: widget.size * 0.2,
          child: _buildEye(widget.size * 0.08),
        ),
        Positioned(
          top: widget.size * 0.25,
          right: widget.size * 0.2,
          child: _buildEye(widget.size * 0.08),
        ),

        // Lông mày - bỏ đi để giống hình hơn
        // Positioned(...) - đã xóa

        // Mũi - nhỏ hơn và đơn giản hơn
        Positioned(
          top: widget.size * 0.4,
          left: 0.0,
          right: 0.0,
          child: Container(
            width: widget.size * 0.03,
            height: widget.size * 0.03,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E1),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Pacifier - thêm chi tiết đặc biệt như trong hình
        Positioned(
          top: widget.size * 0.45,
          left: 0.0,
          right: 0.0,
          child: Container(
            width: widget.size * 0.08,
            height: widget.size * 0.08,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF69B4),
                width: 1,
              ),
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.04,
                height: widget.size * 0.04,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF69B4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: widget.size * 0.02,
                    height: widget.size * 0.02,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Miệng - đơn giản hơn, chỉ là một đường cong nhẹ
        Positioned(
          bottom: widget.size * 0.35,
          left: 0.0,
          right: 0.0,
          child: Container(
            width: widget.size * 0.12,
            height: widget.size * 0.02,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E1),
              borderRadius: BorderRadius.circular(widget.size * 0.01),
            ),
          ),
        ),

        // Má hồng - nhẹ hơn như trong hình
        Positioned(
          bottom: widget.size * 0.25,
          left: widget.size * 0.15,
          child: Container(
            width: widget.size * 0.04,
            height: widget.size * 0.04,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFB6C1).withOpacity(0.3),
            ),
          ),
        ),
        Positioned(
          bottom: widget.size * 0.25,
          right: widget.size * 0.15,
          child: Container(
            width: widget.size * 0.04,
            height: widget.size * 0.04,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFB6C1).withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEye(double eyeSize) {
    return Container(
      width: eyeSize,
      height: eyeSize,
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
  }

  IconData _getMoodIcon() {
    switch (widget.mood) {
      case 'happy':
        return Icons.sentiment_satisfied;
      case 'excited':
        return Icons.sentiment_very_satisfied;
      case 'thinking':
        return Icons.sentiment_neutral;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'celebrating':
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_satisfied;
    }
  }

  Widget _buildHair() {
    return Stack(
      children: [
        // Tóc buộc bên trái - tròn hơn như pigtails
        Positioned(
          top: widget.size * 0.3,
          left: widget.size * 0.02,
          child: Container(
            width: widget.size * 0.2,
            height: widget.size * 0.25,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(widget.size * 0.15),
            ),
          ),
        ),
        
        // Tóc buộc bên phải - tròn hơn như pigtails
        Positioned(
          top: widget.size * 0.3,
          right: widget.size * 0.02,
          child: Container(
            width: widget.size * 0.2,
            height: widget.size * 0.25,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(widget.size * 0.15),
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
      child: Container(
        width: widget.size * 0.7,
        height: widget.size * 0.3,
        decoration: BoxDecoration(
          color: const Color(0xFFDEB887),
          borderRadius: BorderRadius.circular(widget.size * 0.4),
          border: Border.all(
            color: const Color(0xFF8B4513),
            width: 2,
          ),
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
    );
  }

  Widget _buildBag() {
    return Positioned(
      top: widget.size * 0.4,
      left: widget.size * 0.05,
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
    );
  }

  Widget _buildMap() {
    return Positioned(
      top: widget.size * 0.45,
      right: widget.size * 0.05,
      child: Container(
        width: widget.size * 0.2,
        height: widget.size * 0.15,
        decoration: BoxDecoration(
          color: const Color(0xFF556B2F),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFF8B4513),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.map,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildWavingHand() {
    return Stack(
      children: [
        // Tay trái cầm vật trắng như trong hình
        Positioned(
          top: widget.size * 0.4,
          left: widget.size * 0.02,
          child: Container(
            width: widget.size * 0.12,
            height: widget.size * 0.2,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E1),
              borderRadius: BorderRadius.circular(widget.size * 0.1),
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.08,
                height: widget.size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        
        // Tay phải vẫy chào
        Positioned(
          top: widget.size * 0.35,
          right: widget.size * 0.02,
          child: Transform.rotate(
            angle: _waveAnimation.value * 0.5,
            child: Container(
              width: widget.size * 0.12,
              height: widget.size * 0.2,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E1),
                borderRadius: BorderRadius.circular(widget.size * 0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget để test các mood khác nhau
class SenniMoodTester extends StatefulWidget {
  const SenniMoodTester({Key? key}) : super(key: key);

  @override
  State<SenniMoodTester> createState() => _SenniMoodTesterState();
}

class _SenniMoodTesterState extends State<SenniMoodTester> {
  String _currentMood = 'happy';
  bool _showAnimation = true;

  final List<String> _moods = [
    'happy',
    'excited',
    'thinking',
    'sad',
    'celebrating',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌸 Senni Preview'),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Preview Senni
            Center(
              child: SenniPreviewWidget(
                size: 150,
                mood: _currentMood,
                showAnimation: _showAnimation,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAnimation = !_showAnimation;
                    });
                  },
                  child: Text(_showAnimation ? '⏸️ Pause' : '▶️ Play'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentMood = _moods[math.Random().nextInt(_moods.length)];
                    });
                  },
                  child: const Text('🎲 Random Mood'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Mood buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moods.map((mood) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentMood = mood;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentMood == mood 
                        ? Colors.pink.shade200 
                        : Colors.grey.shade200,
                  ),
                  child: Text(_getMoodEmoji(mood)),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Current Mood: $_currentMood',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Animation: ${_showAnimation ? "ON" : "OFF"}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'happy':
        return '😊';
      case 'excited':
        return '🎉';
      case 'thinking':
        return '🤔';
      case 'sad':
        return '😢';
      case 'celebrating':
        return '🌟';
      default:
        return '😊';
    }
  }
} 